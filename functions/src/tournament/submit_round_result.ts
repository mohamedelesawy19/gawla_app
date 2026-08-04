import {getFirestore, Timestamp} from "firebase-admin/firestore";
import {HttpsError, onCall} from "firebase-functions/v2/https";
import {getMiniGameRule} from "./tournament_scoring";
import {closeRound} from "./tournament_round_closer";
import {
  PLAYER_STATUS,
  ROUND_STATUS,
  TOURNAMENTS_COLLECTION,
  TOURNAMENT_STATUS,
  TournamentDoc,
  ROOMS_COLLECTION, ROOM_STATUS} from "./tournament_types";

const db = getFirestore();

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

      const rule = getMiniGameRule(round.miniGameId);
      const plausible = rule.isPlausible(payload);

      round.results.push({
        uid,
        score: plausible ? rule.normalizedScore(payload) : null,
        rank: null,
        eliminated: false,
        submittedAt: Timestamp.now(),
      });

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

      if (tournament.status === TOURNAMENT_STATUS.completed) {
        tx.update(db.collection(ROOMS_COLLECTION).doc(tournament.roomId), {
          status: ROOM_STATUS.closed,
        });
      }
    });
  });
