import {Timestamp} from "firebase-admin/firestore";
import {
  getEliminationStrategy,
} from "./elimination/elimination_strategy_registry";
import {RoundParticipant} from "./elimination/elimination_strategy";
import {
  PLAYER_STATUS,
  ROUND_STATUS,
  TOURNAMENT_STATUS,
  TournamentDoc,
  TournamentPlayerDoc,
  TournamentRoundDoc,
} from "./tournament_types";

/**
 * Ranks/resolves a round's results by delegating to whichever
 * `EliminationStrategy` the round's own `miniGameConfig.eliminationType`
 * declares, applies the resulting eliminations, and either opens the next
 * round (using *its* config, not a global default) or ends the
 * tournament. Mutates `tournament` and `round` in place — the caller
 * writes them back inside its own transaction.
 *
 * This function no longer contains ANY elimination-type-specific logic —
 * that's the actual fix over the previous version, which only ever
 * implemented `rankCutoff` at a hardcoded 25%. See
 * ARCHITECTURE_ANALYSIS.md §Gap 1 for the full rationale.
 *
 * `tournament.players` is a map keyed by uid (mirrors `RoomModel`), so this
 * works over `Object.entries(...)` rather than array methods. Mutating a
 * value obtained from `Object.entries`/`Object.values` still mutates the
 * original map entry, since object values are references.
 *
 * @param {TournamentDoc} tournament Tournament document to mutate in place.
 * @param {TournamentRoundDoc} round Completed round document to mutate.
 */
export function closeRound(
  tournament: TournamentDoc,
  round: TournamentRoundDoc,
): void {
  round.status = ROUND_STATUS.completed;

  const config = round.miniGameConfig;
  const strategy = getEliminationStrategy(config.eliminationType);

  const activeEntries = Object.entries(tournament.players).filter(
    ([, p]) => p.status === PLAYER_STATUS.active,
  );

  const participants: RoundParticipant[] = activeEntries.map(([uid]) => {
    const result = round.results.find((r) => r.uid === uid);
    return {
      uid,
      score: result?.score ?? null,
      passed: result?.passed ?? null,
      groupId: round.groupAssignments?.[uid] ?? null,
    };
  });

  const decision = strategy.resolve(participants, config);

  decision.rankedUids.forEach((uid, i) => {
    const result = round.results.find((r) => r.uid === uid);
    if (result) result.rank = i + 1;
  });
  decision.eliminatedUids.forEach((uid) => {
    const result = round.results.find((r) => r.uid === uid);
    if (result) result.eliminated = true;
  });

  const totalPlayers = Object.keys(tournament.players).length;
  const alreadyPlaced = Object.values(tournament.players).filter(
    (p) => p.finalPlacement !== null,
  ).length;

  // Worst-of-the-eliminated-this-round first, so it gets the numerically
  // worst placement. `decision.rankedUids` is best->worst, so eliminated
  // uids within it are already in best->worst order among themselves;
  // reverse just that slice.
  const eliminatedThisRound = decision.eliminatedUids;
  [...eliminatedThisRound].reverse().forEach((uid, i) => {
    const player = tournament.players[uid];
    if (!player) return;
    player.status = PLAYER_STATUS.eliminated;
    player.eliminatedAtRoundIndex = tournament.currentRoundIndex;
    player.finalPlacement = totalPlayers - alreadyPlaced - i;
  });

  const remainingEntries = Object.entries(tournament.players).filter(
    ([, p]) => p.status === PLAYER_STATUS.active,
  );

  const isFinalRound =
    tournament.currentRoundIndex === tournament.rounds.length - 1;

  if (remainingEntries.length <= 1 || isFinalRound) {
    finishTournament(tournament, remainingEntries);
    return;
  }

  advanceToNextRound(tournament, remainingEntries.map(([uid]) => uid));
}

/**
 * Finalizes placements for remaining players and marks tournament complete.
 *
 * @param {TournamentDoc} tournament Tournament being finalized.
 * @param {Array<[string, TournamentPlayerDoc]>} remainingEntries
 * Remaining active players.
 * @return {void}
 */
function finishTournament(
  tournament: TournamentDoc,
  remainingEntries: Array<[string, TournamentPlayerDoc]>,
): void {
  // No further round data to rank by at this point (elimination already
  // decided the outcome) — remaining players are placed in whatever order
  // they're left in, with the sole survivor (if any) crowned winner.
  remainingEntries.forEach(([, p], i) => {
    p.finalPlacement = i + 1;
    p.status = i === 0 ? PLAYER_STATUS.winner : PLAYER_STATUS.eliminated;
  });

  tournament.status = TOURNAMENT_STATUS.completed;
  tournament.winnerUid = remainingEntries[0]?.[0] ?? null;
  tournament.completedAt = Timestamp.now();
  tournament.currentRoundEndsAt = null;
}

/**
 * Activates the next round and computes round timing/group assignments.
 *
 * @param {TournamentDoc} tournament Tournament to mutate.
 * @param {string[]} remainingActiveUids Active player ids for grouping.
 * @return {void}
 */
function advanceToNextRound(
  tournament: TournamentDoc,
  remainingActiveUids: string[],
): void {
  const nextIndex = tournament.currentRoundIndex + 1;
  const nextRound = tournament.rounds[nextIndex];
  const nextConfig = nextRound.miniGameConfig;
  const nextStrategy = getEliminationStrategy(nextConfig.eliminationType);

  const now = Timestamp.now();
  const endsAt = Timestamp.fromMillis(
    now.toMillis() + nextConfig.roundDurationSec * 1000,
  );

  tournament.currentRoundIndex = nextIndex;
  nextRound.status = ROUND_STATUS.active;
  nextRound.startedAt = now;
  nextRound.endsAt = endsAt;
  nextRound.groupAssignments = nextStrategy.prepareGroups(
    remainingActiveUids,
    nextConfig,
  );
  tournament.currentRoundEndsAt = endsAt;
}
