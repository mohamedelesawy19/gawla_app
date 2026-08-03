import {Timestamp} from "firebase-admin/firestore";
import {
  DEFAULT_ROUND_DURATION_MS,
  ELIMINATION_FRACTION,
  MIN_SURVIVORS_PER_ROUND,
  PLAYER_STATUS,
  ROUND_STATUS,
  TOURNAMENT_STATUS,
  TournamentDoc,
  TournamentPlayerDoc,
  TournamentRoundDoc,
} from "./tournament_types";

/**
 * Ranks a round's results, eliminates the bottom `ELIMINATION_FRACTION` of
 * still-active players, and either opens the next round or ends the
 * tournament. Mutates `tournament` and `round` in place — the caller
 * writes them back inside its own transaction.
 *
 * `tournament.players` is a map keyed by uid (mirrors `RoomModel`), so this
 * works over `Object.entries(...)` rather than array methods. Mutating a
 * value obtained from `Object.entries`/`Object.values` still mutates the
 * original map entry, since object values are references.
 *
 * MVP elimination rule — see prior version's doc comment for the rationale;
 * unchanged apart from the map-based player lookup.
 */
export function closeRound(tournament: TournamentDoc, round: TournamentRoundDoc): void {
  round.status = ROUND_STATUS.completed;

  const scoreOf = (uid: string): number | null =>
    round.results.find((r) => r.uid === uid)?.score ?? null;

  // Best → worst. A null score (voided submission or no-show) always ranks
  // below any real score.
  const byScoreDesc = (
    a: [string, TournamentPlayerDoc],
    b: [string, TournamentPlayerDoc],
  ): number => {
    const scoreA = scoreOf(a[0]);
    const scoreB = scoreOf(b[0]);
    if (scoreA === null && scoreB === null) return 0;
    if (scoreA === null) return 1;
    if (scoreB === null) return -1;
    return scoreB - scoreA;
  };

  const activeEntries = Object.entries(tournament.players).filter(
    ([, p]) => p.status === PLAYER_STATUS.active,
  );
  const ranked = [...activeEntries].sort(byScoreDesc);

  ranked.forEach(([uid], i) => {
    const result = round.results.find((r) => r.uid === uid);
    if (result) result.rank = i + 1;
  });

  const isFinalRound = tournament.currentRoundIndex === tournament.rounds.length - 1;
  const survivorTarget = isFinalRound ?
    1 :
    Math.max(MIN_SURVIVORS_PER_ROUND, Math.ceil(ranked.length * (1 - ELIMINATION_FRACTION)));
  const eliminationCount = Math.max(0, ranked.length - survivorTarget);

  const totalPlayers = Object.keys(tournament.players).length;
  const alreadyPlaced = Object.values(tournament.players).filter(
    (p) => p.finalPlacement !== null,
  ).length;

  // Tail of `ranked` (already sorted best→worst) = this round's cut,
  // ordered best→worst within the eliminated group.
  const eliminatedThisRound = ranked.slice(ranked.length - eliminationCount);
  [...eliminatedThisRound].reverse().forEach(([uid, p], i) => {
    // reversed: worst-of-the-eliminated first, so it gets the numerically
    // worst placement.
    p.status = PLAYER_STATUS.eliminated;
    p.eliminatedAtRoundIndex = tournament.currentRoundIndex;
    p.finalPlacement = totalPlayers - alreadyPlaced - i;
    const result = round.results.find((r) => r.uid === uid);
    if (result) result.eliminated = true;
  });

  const remainingEntries = Object.entries(tournament.players).filter(
    ([, p]) => p.status === PLAYER_STATUS.active,
  );

  if (remainingEntries.length <= 1 || isFinalRound) {
    const finalRanked = [...remainingEntries].sort(byScoreDesc);
    finalRanked.forEach(([, p], i) => {
      p.finalPlacement = i + 1;
      p.status = i === 0 ? PLAYER_STATUS.winner : PLAYER_STATUS.eliminated;
    });

    tournament.status = TOURNAMENT_STATUS.completed;
    tournament.winnerUid = finalRanked[0]?.[0] ?? null;
    tournament.completedAt = Timestamp.now();
    tournament.currentRoundEndsAt = null;
    return;
  }

  const nextIndex = tournament.currentRoundIndex + 1;
  const nextRound = tournament.rounds[nextIndex];
  const now = Timestamp.now();
  const endsAt = Timestamp.fromMillis(now.toMillis() + DEFAULT_ROUND_DURATION_MS);

  tournament.currentRoundIndex = nextIndex;
  nextRound.status = ROUND_STATUS.active;
  nextRound.startedAt = now;
  nextRound.endsAt = endsAt;
  tournament.currentRoundEndsAt = endsAt;
}
