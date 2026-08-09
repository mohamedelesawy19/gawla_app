import {onDocumentWritten} from "firebase-functions/v2/firestore";
import {logger} from "firebase-functions/v2";
import {getDatabase, DataSnapshot} from "firebase-admin/database";
import {
  ROUND_STATUS,
  TOURNAMENTS_COLLECTION,
  TOURNAMENT_STATUS,
  TournamentDoc,
  TournamentRoundDoc,
} from "../../tournament_types";

const rtdb = getDatabase();

// ── Freeze Frenzy tunables (`MINI_GAMES_LIBRARY.md §4.1`) ───────────────────
//
// None of these were pinned down by the library doc or ARCHITECTURE — the
// spec only says "randomly flips", "small grace window" and "45-60s round".
// These are placeholder game-balance numbers, not derived from any provided
// source. They intentionally live here (not in `MiniGameConfig`) because
// nothing in the shared types currently has a slot for them; if design wants
// these tunable without a redeploy the same way `roundDurationSec` is, the
// clean move is adding e.g. `graceWindowMs`/`requiredHoldMs` to
// `MiniGameConfig` and reading them from `round.miniGameConfig` instead.

/** How often the driver re-evaluates state (signal switches, catches, finish
 * line, early-exit). Small enough to feel real-time, large enough to keep
 * RTDB write volume sane for a 45-60s round. */
const TICK_MS = 150;

/** Server-authoritative reaction window after a GREEN→RED switch. Per the
 * anti-cheat note this must never be sent to or influenced by the client. */
const GRACE_WINDOW_MS = 350;

const MIN_GREEN_MS = 1_500;
const MAX_GREEN_MS = 4_000;
const MIN_RED_MS = 1_200;
const MAX_RED_MS = 3_000;

/** Cumulative time a player must spend legitimately holding during GREEN
 * before they're considered to have reached the finish line. Scaled by
 * `MiniGameConfig.difficultyModifier` when the round config sets one. */
const BASE_REQUIRED_HOLD_MS = 9_000;

/** Below this reaction time (release-after-RED, or a held-through-red catch
 * detected right at the grace boundary) we log a review flag per the
 * anti-cheat note about "suspiciously consistent zero-latency stopping".
 * This only flags for later review — it never changes the round outcome. */
const SUSPICIOUS_REACTION_MS = 50;

type Signal = "green" | "red";

interface FreezeFrenzyHoldEvent {
  uid?: unknown;
  holding?: unknown;
}

/** Per-player bookkeeping kept in the driver's own memory for the lifetime
 * of a single round. Nothing here is persisted as-is — RTDB only ever sees
 * the derived `caught_<uid>` / `reachedFinish_<uid>` booleans, matching
 * `FreezeFrenzyDefinition`'s documented channel schema exactly. */
interface PlayerProgress {
  /** Green-only held time banked so far (excludes any hold in progress). */
  totalHeldMs: number;
  /** Server timestamp the current hold started, iff `holding` and the
   * signal was GREEN at that moment. `null` when not currently accruing. */
  holdStartedAtMs: number | null;
  /** Currently pressing MOVE, per the latest event we've processed. */
  holding: boolean;
  resolved: boolean;
}

/**
 * Cloud Function entry point. Unlike `driveTugOfPowerRound` (a pure RTDB
 * event aggregator — Tug of Power has no server-owned clock of its own),
 * Freeze Frenzy's fairness hinges on a schedule only the server may know in
 * advance, so something has to *start* owning that schedule the instant the
 * round goes active. This is that "something": it watches the tournament
 * doc, and when it sees the current round transition into
 * `active` with `gameId === "freeze_frenzy"`, it runs the entire round —
 * signal schedule, catch detection, finish detection — to completion in a
 * single execution.
 *
 * This is new plumbing this game introduces to the Tournament Engine:
 * every other mini-game so far is driven by client-submitted results
 * (`submitRoundResult`) or reactive per-event aggregation
 * (`driveTugOfPowerRound`). Whatever function currently flips
 * `rounds[i].status` to `"active"` (not part of the provided source — a
 * candidate is `advanceStaleTournamentRounds`, but it may be a different
 * activator entirely) doesn't need to know or care about this; it just
 * needs to keep writing that transition the way it already does.
 *
 * This must react to both document creation and updates because the first
 * tournament round is created already `active` by `startTournament`, while
 * later rounds become active via `closeRound`.
 */
export const driveFreezeFrenzyRound = onDocumentWritten(
  {
    region: "europe-west1",
    document: `${TOURNAMENTS_COLLECTION}/{tournamentId}`,
    timeoutSeconds: 120,
  },
  async (event) => {
    const tournamentId = event.params.tournamentId as string;
    const before = event.data?.before?.data() as TournamentDoc | undefined;
    const after = event.data?.after?.data() as TournamentDoc | undefined;

    if (!after || after.status !== TOURNAMENT_STATUS.inProgress) return;

    const roundIndex = after.currentRoundIndex;
    const round = after.rounds[roundIndex];

    if (round?.status !== ROUND_STATUS.active) return;
    if (round.miniGameConfig?.gameId !== "freeze_frenzy") return;

    const becameActive =
      before?.status !== TOURNAMENT_STATUS.inProgress ||
      before?.currentRoundIndex !== roundIndex ||
      before?.rounds[roundIndex]?.status !== ROUND_STATUS.active ||
      before?.rounds[roundIndex]?.miniGameConfig?.gameId !== "freeze_frenzy";
    if (!becameActive) {
      // Ignore unrelated field updates on an already-running round.
      return;
    }

    const activeUids = Object.entries(after.players)
      .filter(([, p]) => p.status === "active")
      .map(([uid]) => uid);

    if (activeUids.length === 0) {
      logger.warn("freeze_frenzy: round activated with no active players", {
        tournamentId, roundIndex,
      });
      return;
    }

    await runFreezeFrenzyRound({
      tournamentId,
      roundIndex,
      round,
      activeUids,
    });
  },
);

/**
 * Runs one Freeze Frenzy round end-to-end: claims the round, owns the
 * RED/GREEN clock, resolves catches and finishes as they happen, and
 * marks the channel `ended` once the round is decided. Everything the
 * `_FreezeFrenzyGameWidgetState` reads (`signal`, `ended`, `caught_<uid>`,
 * `reachedFinish_<uid>`) is written from here and nowhere else.
 *
 * @param {object} params Round execution parameters.
 */
async function runFreezeFrenzyRound(params: {
  tournamentId: string;
  roundIndex: number;
  round: TournamentRoundDoc;
  activeUids: string[];
}): Promise<void> {
  const {tournamentId, roundIndex, round, activeUids} = params;
  const channelRef = rtdb.ref(
    `miniGameChannels/${tournamentId}/${roundIndex}/freeze_frenzy`,
  );

  // ── Claim the round ────────────────────────────────────────────────────
  // At-least-once Firestore trigger delivery means this function body can
  // run twice for the same activation. Only the instance that wins this
  // transaction gets to drive the round; the loser returns immediately.
  // This is the same "idempotent Cloud Function" guarantee the anti-cheat
  // table asks for, applied to round-driving rather than result-submission.
  const claim = await channelRef.child("_driverClaimedAtMs").transaction(
    (current) => (current === null ? Date.now() : undefined),
  );
  if (!claim.committed) {
    logger.info("freeze_frenzy: round already claimed, skipping", {
      tournamentId, roundIndex,
    });
    return;
  }

  const roundDurationMs = round.miniGameConfig.roundDurationSec * 1000;
  const requiredHoldMs = Math.round(
    BASE_REQUIRED_HOLD_MS * (round.miniGameConfig.difficultyModifier ?? 1),
  );

  // Reset the channel to a clean initial state (the claim above already
  // guarantees only one instance reaches this point, so `.set()` here is
  // safe — there's nothing concurrent that could race it).
  const initialSignal: Signal = "green";
  await channelRef.update({signal: initialSignal, ended: false});

  const progress = new Map<string, PlayerProgress>(
    activeUids.map((uid) => [uid, {
      totalHeldMs: 0,
      holdStartedAtMs: null,
      holding: false,
      resolved: false,
    }]),
  );

  let signal: Signal = "green";
  let redGraceDeadlineMs: number | null = null;
  const startedAtMs = Date.now();
  let nextSwitchAtMs = startedAtMs + randomBetween(MIN_GREEN_MS, MAX_GREEN_MS);
  const roundEndsAtMs = startedAtMs + roundDurationMs;

  const markCaught = (uid: string, now: number, source: string) => {
    const p = progress.get(uid);
    if (!p || p.resolved) return;
    p.resolved = true;
    p.holding = false;
    p.holdStartedAtMs = null;
    channelRef.child(`caught_${uid}`).set(true).catch((err) =>
      logger.error("freeze_frenzy: failed to write caught flag", {
        tournamentId, roundIndex, uid, err,
      }),
    );
    logger.info("freeze_frenzy: player caught", {
      tournamentId, roundIndex, uid, source,
    });
  };

  const markReachedFinish = (uid: string) => {
    const p = progress.get(uid);
    if (!p || p.resolved) return;
    p.resolved = true;
    p.holding = false;
    p.holdStartedAtMs = null;
    channelRef.child(`reachedFinish_${uid}`).set(true).catch((err) =>
      logger.error("freeze_frenzy: failed to write finish flag", {
        tournamentId, roundIndex, uid, err,
      }),
    );
  };

  // ── Live hold/release events from every player in the round ────────────
  // Kept as a plain Admin SDK listener (not a separate function export)
  // deliberately: catch/finish resolution needs the *same* in-memory
  // `signal` / `redGraceDeadlineMs` / `progress` state the tick loop below
  // owns, and RTDB gives us no cheap way to share that across function
  // invocations without round-tripping it through the database on every
  // single tap — which is exactly the per-event Firestore read
  // `driveTugOfPowerRound` already accepts for its much lower-stakes live
  // meter, but is too slow for a hard elimination decision here.
  const eventsRef = channelRef.child("events");
  const onHoldEvent = (snapshot: DataSnapshot) => {
    const raw = snapshot.val() as FreezeFrenzyHoldEvent;
    const uid = typeof raw?.uid === "string" ? raw.uid : null;
    const holding = typeof raw?.holding === "boolean" ? raw.holding : null;
    if (!uid || holding === null) {
      logger.warn("freeze_frenzy: malformed hold event, ignoring", {
        tournamentId, roundIndex, raw,
      });
      return;
    }

    const p = progress.get(uid);
    if (!p || p.resolved) return;

    const now = Date.now();
    p.holding = holding;

    if (holding) {
      const pastGrace = signal === "red" &&
        (redGraceDeadlineMs === null || now >= redGraceDeadlineMs);
      if (pastGrace) {
        markCaught(uid, now, "hold-event-during-red");
        return;
      }
      if (signal === "green") {
        p.holdStartedAtMs = now;
      }
      // Holding starts/continues inside the grace window: forgiven for now
      // — the deadline sweep in the tick loop below will catch them if
      // they're still holding once the grace window actually closes.
    } else {
      if (signal === "green" && p.holdStartedAtMs !== null) {
        p.totalHeldMs += now - p.holdStartedAtMs;
      }
      p.holdStartedAtMs = null;

      if (signal === "red" && redGraceDeadlineMs !== null) {
        const reactionMs = now - (redGraceDeadlineMs - GRACE_WINDOW_MS);
        if (reactionMs >= 0 && reactionMs < SUSPICIOUS_REACTION_MS) {
          logger.warn("freeze_frenzy: suspiciously fast red reaction", {
            tournamentId, roundIndex, uid, reactionMs,
          });
        }
      }

      if (p.totalHeldMs >= requiredHoldMs) {
        markReachedFinish(uid);
      }
    }
  };
  eventsRef.on("child_added", onHoldEvent);

  try {
    while (Date.now() < roundEndsAtMs) {
      await sleep(TICK_MS);
      const now = Date.now();

      // Progress check: a player who never releases (holds continuously
      // through the finish line) never fires a "holding:false" event, so
      // the finish check above alone would never catch them. Sweep here.
      if (signal === "green") {
        for (const [uid, p] of progress) {
          if (p.resolved || !p.holding || p.holdStartedAtMs === null) {
            continue;
          }
          const heldMs = p.totalHeldMs + (now - p.holdStartedAtMs);
          if (heldMs >= requiredHoldMs) markReachedFinish(uid);
        }
      }

      // Red grace deadline: catch anyone still holding once the reaction
      // window has closed, regardless of whether a fresh event arrives.
      if (signal === "red" && redGraceDeadlineMs !== null &&
          now >= redGraceDeadlineMs) {
        for (const [uid, p] of progress) {
          if (!p.resolved && p.holding) {
            markCaught(uid, now, "grace-deadline-sweep");
          }
        }
        redGraceDeadlineMs = null; // only sweep once per RED interval
      }

      // Signal switch.
      if (now >= nextSwitchAtMs) {
        signal = signal === "green" ? "red" : "green";
        await channelRef.update({signal});

        if (signal === "red") {
          redGraceDeadlineMs = now + GRACE_WINDOW_MS;
          // Bank partial GREEN progress for anyone still holding at the
          // instant of the switch — it shouldn't keep accruing during RED,
          // win or lose, since only GREEN time counts toward the finish
          // line per the "GREEN = move freely" mechanic.
          for (const p of progress.values()) {
            if (p.holding && p.holdStartedAtMs !== null) {
              p.totalHeldMs += now - p.holdStartedAtMs;
              p.holdStartedAtMs = null;
            }
          }
        } else {
          for (const p of progress.values()) {
            if (p.holding) p.holdStartedAtMs = now;
          }
        }

        nextSwitchAtMs = now + (signal === "green" ?
          randomBetween(MIN_GREEN_MS, MAX_GREEN_MS) :
          randomBetween(MIN_RED_MS, MAX_RED_MS));
      }

      if ([...progress.values()].every((p) => p.resolved)) break;
    }
  } finally {
    eventsRef.off("child_added", onHoldEvent);
  }

  // Anyone still unresolved when we get here simply ran out of time —
  // `caught_<uid>` / `reachedFinish_<uid>` are left unset, which the widget
  // (and `freezeFrenzyDefinition.normalize`) already treat as `false`, so
  // there's nothing to write for them beyond `ended`.
  await channelRef.update({ended: true});
  logger.info("freeze_frenzy: round ended", {
    tournamentId,
    roundIndex,
    resolvedEarly: Date.now() < roundEndsAtMs,
  });
}

/**
 * Returns a random integer within the inclusive range.
 *
 * @param {number} minInclusive Minimum possible value.
 * @param {number} maxInclusive Maximum possible value.
 * @return {number} A random integer within the inclusive range.
 */
function randomBetween(minInclusive: number, maxInclusive: number): number {
  return Math.floor(
    minInclusive + Math.random() * (maxInclusive - minInclusive + 1),
  );
}

/**
 * Resolves after the specified delay.
 *
 * @param {number} ms Delay in milliseconds.
 * @return {Promise<void>} A promise that resolves after the delay.
 */
function sleep(ms: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, ms));
}
