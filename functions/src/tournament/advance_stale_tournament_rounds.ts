import {getFirestore, Timestamp} from "firebase-admin/firestore";
import {onSchedule} from "firebase-functions/v2/scheduler";
import {closeRound} from "./tournament_round_closer";
import {
  ROUND_STATUS,
  TOURNAMENTS_COLLECTION,
  TOURNAMENT_STATUS,
  TournamentDoc,
} from "./tournament_types";

const db = getFirestore();

/**
 * Safety net for rounds nobody explicitly closes: if every active player
 * already submitted, `submitRoundResult` closes the round itself. This
 * scheduled function catches the other case — a round whose `endsAt` has
 * passed with players still missing (disconnected, AFK, an unresolved duel
 * tie, ...) — and force-closes it via the same `closeRound` orchestration,
 * which delegates to whichever `EliminationStrategy` the round's
 * `miniGameConfig.eliminationType` declares. Every built-in strategy
 * treats a missing submission as an automatic loss (see
 * `elimination_strategy.ts`'s doc comment on `RoundParticipant`), so this
 * function never needs its own elimination-type-specific logic — same as
 * `submitRoundResult`'s early-close path.
 *
 * Runs every minute; cheap given a tournament only lives ~5-8 minutes
 * total and there should be very few `inProgress` tournaments at once.
 *
 * NOTE: this query needs a composite index on
 * (status ASC, currentRoundEndsAt ASC). Firestore will log a console link
 * to create it the first time this runs against real data if it's
 * missing.
 */
export const advanceStaleTournamentRounds = onSchedule(
  "every 1 minutes",
  async () => {
    const now = Timestamp.now();

    const staleTournaments = await db
      .collection(TOURNAMENTS_COLLECTION)
      .where("status", "==", TOURNAMENT_STATUS.inProgress)
      .where("currentRoundEndsAt", "<=", now)
      .get();

    await Promise.all(
      staleTournaments.docs.map((doc) =>
        db.runTransaction(async (tx) => {
          const snap = await tx.get(doc.ref);
          if (!snap.exists) return;

          const tournament = snap.data() as TournamentDoc;

          // Re-check inside the transaction: another scheduler run, or a
          // last-second `submitRoundResult` call, may have already closed
          // this round between the query above and this read.
          if (tournament.status !== TOURNAMENT_STATUS.inProgress) return;

          const round = tournament.rounds[tournament.currentRoundIndex];
          if (!round || round.status !== ROUND_STATUS.active) return;
          if (!round.endsAt || round.endsAt.toMillis() > now.toMillis()) return;

          closeRound(tournament, round);

          tx.update(doc.ref, {
            rounds: tournament.rounds,
            players: tournament.players,
            currentRoundIndex: tournament.currentRoundIndex,
            currentRoundEndsAt: tournament.currentRoundEndsAt,
            status: tournament.status,
            winnerUid: tournament.winnerUid,
            completedAt: tournament.completedAt,
          });
        }),
      ),
    );
  });
