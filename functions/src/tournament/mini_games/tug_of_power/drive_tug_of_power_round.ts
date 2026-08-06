import {onValueCreated} from "firebase-functions/v2/database";
import {logger} from "firebase-functions/v2";
import {getDatabase} from "firebase-admin/database";
import {getFirestore} from "firebase-admin/firestore";
import {
  ROUND_STATUS,
  TOURNAMENTS_COLLECTION,
  TOURNAMENT_STATUS,
  TournamentDoc,
} from "../../tournament_types";
import {MAX_TAPS_PER_SECOND} from "../team_games";

const db = getFirestore();
const rtdb = getDatabase();

type TeamId = "teamA" | "teamB";

interface TugOfPowerTapEvent {
  uid?: unknown;
  taps?: unknown;
  clientSentAtMs?: unknown;
}

interface ActiveTugOfPowerRound {
  tournamentId: string;
  groupAssignments: Record<string, string>;
  startedAtMs: number;
}

interface CachedRound {
  value: ActiveTugOfPowerRound;
  expiresAt: number;
}

const roundCache = new Map<string, CachedRound>();

const CACHE_TTL_MS = 10_000;

/**
 * Returns the active Tug of Power round for the given tournament.
 *
 * @param {string} tournamentId Tournament document id.
 * @param {number} roundIndex Current round index.
 * @return {Promise<ActiveTugOfPowerRound | null>} Active round context,
 * or `null` if no active Tug of Power round exists.
 */
async function findActiveTugOfPowerRound(
  tournamentId: string,
  roundIndex: number,
): Promise<ActiveTugOfPowerRound | null> {
  const cacheKey = `${tournamentId}:${roundIndex}`;

  const cached = roundCache.get(cacheKey);

  if (cached && cached.expiresAt > Date.now()) {
    return cached.value;
  }

  const doc = await db
    .collection(TOURNAMENTS_COLLECTION)
    .doc(tournamentId)
    .get();

  if (!doc.exists) return null;

  const tournament = doc.data() as TournamentDoc;

  if (tournament.status !== TOURNAMENT_STATUS.inProgress) {
    return null;
  }

  const round = tournament.rounds[roundIndex];

  if (
    round?.status !== ROUND_STATUS.active ||
    round.miniGameConfig?.gameId !== "tug_of_power" ||
    round.groupAssignments == null
  ) {
    roundCache.delete(cacheKey);
    return null;
  }

  const result: ActiveTugOfPowerRound = {
    tournamentId,
    groupAssignments: round.groupAssignments as Record<string, string>,
    startedAtMs: round.startedAt?.toMillis() ?? Date.now(),
  };

  roundCache.set(cacheKey, {
    value: result,
    expiresAt: Date.now() + CACHE_TTL_MS,
  });

  return result;
}

/**
 * RTDB-triggered driver for Tug of Power's live team-power meter — the
 * backend counterpart `RealtimeGameChannel`'s doc comment calls out as
 * a genuine new surface this Flutter feature depends on but doesn't
 * implement. Aggregates each player's raw tap events into
 * `miniGameChannels/{tournamentId}/{roundIndex}/tug_of_power/
 *  teamPower/teamPower`
 *  which `_TugOfPowerGameWidgetState` renders as the pull bar.
 *
 * This ONLY drives the live/cosmetic meter. It has no bearing on the
 * actual elimination decision — that's `submitRoundResult` +
 * `tugOfPowerDefinition.normalize` + `teamLossStrategy`, already
 * independent of this file and already correct.
 */
export const driveTugOfPowerRound = onValueCreated(
  {
    region: "europe-west1",
    ref:
        "/miniGameChannels/{tournamentId}/" +
        "{roundIndex}/tug_of_power/events/{eventId}",
  },
  async (event) => {
    const roundIndex = Number(event.params.roundIndex);
    if (!Number.isInteger(roundIndex) || roundIndex < 0) {
      logger.warn("tug_of_power: malformed roundIndex param", {
        raw: event.params.roundIndex,
      });
      return;
    }

    const tap = event.data.val() as TugOfPowerTapEvent;
    const uid = typeof tap?.uid === "string" ? tap.uid : null;
    const rawTaps =
      typeof tap?.taps === "number" && Number.isFinite(tap.taps) ?
        tap.taps :
        null;

    if (!uid || rawTaps === null || rawTaps < 0) {
      logger.warn("tug_of_power: malformed event, ignoring", {
        roundIndex, tap,
      });
      return;
    }

    const roundInfo = await findActiveTugOfPowerRound(
      event.params.tournamentId,
      roundIndex,
    );

    if (!roundInfo) {
      // Rare benign race (event lands a beat before groupAssignments
      // commits) or a genuinely stale/orphaned event — either way, safe
      // to just drop it; this only drives a cosmetic live bar.
      logger.warn("tug_of_power: no matching active round found", {
        roundIndex, uid,
      });
      return;
    }

    const team = roundInfo.groupAssignments[uid] as TeamId | undefined;
    if (team !== "teamA" && team !== "teamB") {
      logger.warn("tug_of_power: uid has no team assignment", {
        roundIndex, uid,
      });
      return;
    }

    // `taps` sent by `TugOfPowerDefinition._tap` is this player's
    // CUMULATIVE tap count so far (every event repeats the running
    // total), not a per-event delta. Sanity-cap it against elapsed time
    // using the same per-second rate `tugOfPowerDefinition.isPlausible`
    // enforces on the final Firestore submission — this has zero bearing
    // on the actual elimination decision (re-validated independently by
    // `submit_round_result.ts`), it just stops the live bar itself from
    // being griefed.
    const elapsedSeconds = Math.max(
      0,
      (Date.now() - roundInfo.startedAtMs) / 1000,
    );
    const maxPlausibleTaps = Math.ceil(
      (elapsedSeconds + 1) * MAX_TAPS_PER_SECOND,
    );
    const cappedTaps = Math.min(rawTaps, maxPlausibleTaps);

    const channelRef = rtdb.ref(
      `miniGameChannels/${roundInfo.tournamentId}/${roundIndex}/tug_of_power`
    );

    // Store the latest cumulative value seen per uid, and add only the
    // DELTA to the team total — otherwise every event would re-add taps
    // a previous event from the same player already counted.
    let previousTaps = 0;
    const latestResult = await channelRef
      .child(`latestByUid/${uid}`)
      .transaction((current: number | null) => {
        previousTaps = typeof current === "number" ? current : 0;
        return Math.max(previousTaps, cappedTaps);
      });

    if (!latestResult.committed) return;

    const newTaps = latestResult.snapshot.val() as number;
    const delta = newTaps - previousTaps;
    if (delta <= 0) return; // stale/duplicate/out-of-order event

    await channelRef
      .child(`teamPower/${team}`)
      .transaction((current: number | null) => (current ?? 0) + delta);
  },
);
