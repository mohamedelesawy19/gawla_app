import {Timestamp} from "firebase-admin/firestore";
import {HttpsError, onCall} from "firebase-functions/v2/https";
import {closeRound} from "./tournament_round_closer";
import {getMiniGameDefinition} from "./mini_games/mini_game_registry";
import {db} from "../shared/firestore";
import {
  DUEL_COMMITS_SUBCOLLECTION,
  PLAYER_STATUS,
  ROUND_STATUS,
  TOURNAMENTS_COLLECTION,
  TOURNAMENT_STATUS,
  TournamentDoc,
  RoundResultDoc} from "./tournament_types";

interface SubmitRoundResultRequest {
  tournamentId: string;
  roundIndex: number;
  payload: Record<string, unknown>;
}

/**
 * Submits a player's raw result for the tournament's current round. Every
 * check here mirrors (and re-verifies server-side) what
 * `RoundSubmissionValidator` already ruled out client-side — a submission
 * that passes the client check can still be rejected here, and this is the
 * only version that actually counts.
 *
 * All scoring, ranking, and elimination happen inside the same
 * transaction as the write, so concurrent submissions from other players
 * can never race each other into an inconsistent `rounds` array.
 *
 * DUEL ROUNDS (`eliminationType === "duelLoser"`) take a different path
 * within this same transaction: rather than pushing a plain normalized
 * result, the raw payload is written to a private, server-only commit
 * doc (`DUEL_COMMITS_SUBCOLLECTION` — never client-readable, see that
 * constant's doc comment for the required security rule) and the two
 * duelists' outcomes are resolved together the moment the SECOND one
 * commits. This is what satisfies `MINI_GAMES_LIBRARY.md §4.6`'s
 * "commit-then-reveal... never let a client see the opponent's choice
 * before its own is submitted" requirement — a duelist's raw choice is
 * never written anywhere the other duelist's client could read it before
 * their own submission lands. A tie leaves both duelists' entries off
 * `round.results` entirely so they can resubmit for an immediate
 * rematch; if the round times out before they do,
 * `advance_stale_tournament_rounds.ts`'s stale-close path treats them as
 * no-shows, which `duelLoserStrategy` eliminates like any other no-show —
 * so a tie can never stall a round forever.
 */
export const submitRoundResult = onCall<SubmitRoundResultRequest>(
  async (request) => {
    const uid = request.auth?.uid;
    if (!uid) {
      throw new HttpsError(
        "unauthenticated",
        "You must be signed in to submit a result.",
      );
    }

    const {tournamentId, roundIndex, payload} = request.data ?? {};
    if (!tournamentId || typeof tournamentId !== "string") {
      throw new HttpsError(
        "invalid-argument",
        "tournamentId is required.",
      );
    }
    if (
      typeof roundIndex !== "number" ||
    !Number.isInteger(roundIndex) ||
    roundIndex < 0
    ) {
      throw new HttpsError(
        "invalid-argument",
        "roundIndex must be a non-negative integer.",
      );
    }
    if (
      payload === null ||
    typeof payload !== "object" ||
    Array.isArray(payload)
    ) {
      throw new HttpsError(
        "invalid-argument",
        "payload must be an object.",
      );
    }

    const tournamentRef = db
      .collection(TOURNAMENTS_COLLECTION)
      .doc(tournamentId);

    await db.runTransaction(async (tx) => {
      const snap = await tx.get(tournamentRef);
      if (!snap.exists) {
        throw new HttpsError("not-found", "Tournament not found.");
      }

      const tournament = snap.data() as TournamentDoc;

      if (tournament.status !== TOURNAMENT_STATUS.inProgress) {
        throw new HttpsError(
          "failed-precondition",
          "This tournament is not currently active.",
        );
      }
      if (tournament.currentRoundIndex !== roundIndex) {
        throw new HttpsError(
          "failed-precondition",
          "This round is no longer accepting submissions.",
        );
      }

      const player = tournament.players[uid];
      if (!player) {
        throw new HttpsError(
          "permission-denied",
          "You are not a participant in this tournament.",
        );
      }
      if (player.status !== PLAYER_STATUS.active) {
        throw new HttpsError(
          "failed-precondition",
          "You have already been eliminated.",
        );
      }

      const round = tournament.rounds[roundIndex];
      if (!round || round.status !== ROUND_STATUS.active) {
        throw new HttpsError(
          "failed-precondition",
          "This round is not currently open.",
        );
      }
      if (round.results.some((r) => r.uid === uid)) {
        throw new HttpsError(
          "already-exists",
          "You already submitted a result for this round.",
        );
      }

      const config = round.miniGameConfig;
      const definition = getMiniGameDefinition(config.gameId);
      const plausible = definition.isPlausible(payload);
      const groupId = round.groupAssignments?.[uid] ?? null;

      if (config.eliminationType === "duelLoser" && definition.resolveDuel) {
        // ── Duel path: read the opponent's commit doc (all reads must
        // happen before any writes in a Firestore transaction) before
        // deciding anything. ──────────────────────────────────────────
        const opponentUid = groupId === null ? null : Object.entries(
          round.groupAssignments ?? {},
        ).find(([otherUid, otherGroup]) =>
          otherUid !== uid && otherGroup === groupId,
        )?.[0] ?? null;

        const opponentCommitRef = opponentUid ? tournamentRef
          .collection(DUEL_COMMITS_SUBCOLLECTION)
          .doc(`${roundIndex}_${opponentUid}`) : null;
        const opponentCommitSnap = opponentCommitRef ?
          await tx.get(opponentCommitRef) :
          null;

        resolveDuelSubmission({
          tx,
          tournamentRef,
          tournament,
          round,
          roundIndex,
          uid,
          opponentUid,
          groupId,
          payload,
          plausible,
          definition,
          opponentCommitSnap,
        });
      } else {
        const normalized = plausible ?
          definition.normalize(payload) :
          {score: null, passed: false};
        round.results.push({
          uid,
          score: normalized.score,
          passed: normalized.passed,
          rank: null,
          eliminated: false,
          submittedAt: Timestamp.now(),
          groupId,
          metadata: null,
        });
      }

      const activePlayerUids = Object.entries(tournament.players)
        .filter(([, p]) => p.status === PLAYER_STATUS.active)
        .map(([playerUid]) => playerUid);
      const allActiveSubmitted = activePlayerUids.every((playerUid) =>
        round.results.some((r) => r.uid === playerUid),
      );

      if (allActiveSubmitted) {
        closeRound(tournament, round);
      }

      tx.update(tournamentRef, {
        rounds: tournament.rounds,
        players: tournament.players,
        currentRoundIndex: tournament.currentRoundIndex,
        currentRoundEndsAt: tournament.currentRoundEndsAt,
        status: tournament.status,
        winnerUid: tournament.winnerUid,
        completedAt: tournament.completedAt,
      });
    });
  });

interface ResolveDuelSubmissionArgs {
  tx: FirebaseFirestore.Transaction;
  tournamentRef: FirebaseFirestore.DocumentReference;
  tournament: TournamentDoc;
  round: TournamentDoc["rounds"][number];
  roundIndex: number;
  uid: string;
  opponentUid: string | null;
  groupId: string | null;
  payload: Record<string, unknown>;
  plausible: boolean;
  definition: ReturnType<typeof getMiniGameDefinition>;
  opponentCommitSnap: FirebaseFirestore.DocumentSnapshot | null;
}

/**
 * Resolves a duel submission, either by storing a pending commit for the
 * first submitter or finalizing both outcomes when both commits exist.
 *
 * @param {ResolveDuelSubmissionArgs} args Duel resolution context.
 * @return {void}
 */
function resolveDuelSubmission(args: ResolveDuelSubmissionArgs): void {
  const {
    tx, tournamentRef, round, roundIndex, uid, opponentUid, groupId,
    payload, plausible, definition, opponentCommitSnap,
  } = args;

  const myCommitRef = tournamentRef
    .collection(DUEL_COMMITS_SUBCOLLECTION)
    .doc(`${roundIndex}_${uid}`);

  const pushPending = (): void => {
    round.results.push({
      uid,
      score: null,
      passed: null, // pending — resolved when the opponent commits
      rank: null,
      eliminated: false,
      submittedAt: Timestamp.now(),
      groupId,
      metadata: null,
    });
  };

  if (!plausible) {
    // Invalid payload is an automatic loss — no need to wait on the
    // opponent at all.
    round.results.push({
      uid, score: null, passed: false, rank: null, eliminated: false,
      submittedAt: Timestamp.now(), groupId, metadata: null,
    });
    return;
  }

  if (!opponentUid || !opponentCommitSnap || !opponentCommitSnap.exists) {
    // First to commit (or a bye with no opponent, though byes never reach
    // this branch since `duelLoserStrategy` only checks `groupId`). Record
    // the raw choice privately and mark this player's result as pending.
    tx.set(myCommitRef, {payload, submittedAt: Timestamp.now()});
    pushPending();
    return;
  }

  // Second to commit — resolve now, inside this same transaction.
  const opponentPayload = opponentCommitSnap.data()?.payload as
    Record<string, unknown>;
  const resolveDuel = definition.resolveDuel;
  if (!resolveDuel) {
    // Duel games must define this; if missing, fail closed for safety.
    round.results.push({
      uid, score: null, passed: false, rank: null, eliminated: false,
      submittedAt: Timestamp.now(), groupId, metadata: null,
    });
    return;
  }
  const winner = resolveDuel(payload, opponentPayload);

  if (winner === "tie") {
    // Neither result is recorded — both duelists re-submit for an
    // immediate rematch. Also clear the opponent's now-stale commit doc
    // and their earlier pending result entry.
    tx.delete(myCommitRef);
    const opponentCommitRef = tournamentRef
      .collection(DUEL_COMMITS_SUBCOLLECTION)
      .doc(`${roundIndex}_${opponentUid}`);
    tx.delete(opponentCommitRef);
    round.results = round.results.filter((r) => r.uid !== opponentUid);
    return;
  }

  const iWon = winner === "a";
  // `resolveDuel(payload, opponentPayload)` -> "a" means this payload won.
  const revealMetadata = {
    myChoice: (payload as {choice?: unknown}).choice ?? null,
    opponentChoice: (opponentPayload as {choice?: unknown}).choice ?? null,
  };

  round.results.push({
    uid, score: null, passed: iWon, rank: null, eliminated: false,
    submittedAt: Timestamp.now(), groupId, metadata: revealMetadata,
  });
  const opponentResult = round.results.find(
    (r: RoundResultDoc) => r.uid === opponentUid,
  );
  if (opponentResult) {
    opponentResult.passed = !iWon;
    opponentResult.metadata = {
      myChoice: revealMetadata.opponentChoice,
      opponentChoice: revealMetadata.myChoice,
    };
  }
}
