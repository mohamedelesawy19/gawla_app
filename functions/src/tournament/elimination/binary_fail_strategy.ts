import {
  EliminationDecision,
  EliminationStrategy,
  RoundParticipant,
} from "./elimination_strategy";

/**
 * Binary Pass/Fail elimination (`MINI_GAMES_LIBRARY.md §1`): anyone whose
 * normalized outcome is `passed !== true` is out — one mistake (or a
 * no-show, `score === null && passed === null`) ends the run, no ranking
 * involved. Used directly by `binaryFail` games (Freeze Frenzy, Tile Trap,
 * Trace the Shape) and reused as-is by `survivalFailStrategy` /
 * `duelLoserStrategy`, since both reduce to the same "did this player end
 * the round in a passed state" question by the time `resolve` runs — see
 * those files' doc comments for why the *earlier* steps differ but the
 * elimination decision itself doesn't need to.
 */
export const binaryFailStrategy: EliminationStrategy = {
  prepareGroups: () => null,

  resolve(participants: RoundParticipant[]): EliminationDecision {
    const eliminatedUids = participants
      .filter((p) => p.passed !== true)
      .map((p) => p.uid);
    const survivedUids = participants
      .filter((p) => p.passed === true)
      .map((p) => p.uid);

    return {
      eliminatedUids,
      rankedUids: [...survivedUids, ...eliminatedUids],
    };
  },
};
