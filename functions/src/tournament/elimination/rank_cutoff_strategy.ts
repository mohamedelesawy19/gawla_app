import {MiniGameConfig} from "../tournament_types";
import {
  EliminationDecision,
  EliminationStrategy,
  RoundParticipant,
} from "./elimination_strategy";
import {resolveEliminationCount} from "./elimination_utils";

/**
 * Threshold/Rank elimination (`MINI_GAMES_LIBRARY.md §1`): rank the pool by
 * score, cut the bottom `config.eliminationTarget`. This is a direct port
 * of the ranking logic that used to live inline in
 * `tournament_round_closer.ts`, generalized to read its cut size from the
 * round's own config instead of the old global `ELIMINATION_FRACTION`.
 *
 * Also honors "false starts always cut regardless of rank"
 * (`MINI_GAMES_LIBRARY.md §4.3`, Musical Freeze): a participant with
 * `passed === false` is a forced elimination — e.g. a Reaction Tap/Musical
 * Freeze false start — and is always cut, independent of the percentage
 * target. The target's cut count still includes these forced-outs (they're
 * already "the worst"), so the *additional* score-based cut only removes
 * `target - forcedOut.length` more players from the remaining pool.
 */
export const rankCutoffStrategy: EliminationStrategy = {
  prepareGroups: () => null,

  resolve(
    participants: RoundParticipant[],
    config: MiniGameConfig,
  ): EliminationDecision {
    const forcedOut = participants.filter((p) => p.passed === false);
    const rankable = participants.filter((p) => p.passed !== false);

    // Best -> worst. A null score (no submission, or a voided/implausible
    // submission per the mini-game's `isPlausible` check) always ranks
    // below any real score.
    const byScoreDesc = (a: RoundParticipant, b: RoundParticipant): number => {
      if (a.score === null && b.score === null) return 0;
      if (a.score === null) return 1;
      if (b.score === null) return -1;
      return b.score - a.score;
    };
    const ranked = [...rankable].sort(byScoreDesc);

    const totalCut = resolveEliminationCount(
      config.eliminationTarget,
      participants.length,
    );
    const additionalCut = Math.max(0, totalCut - forcedOut.length);
    const scoreEliminated = ranked.slice(ranked.length - additionalCut);

    const eliminatedUids = [
      ...forcedOut.map((p) => p.uid),
      ...scoreEliminated.map((p) => p.uid),
    ];

    return {
      eliminatedUids,
      rankedUids: [
        ...ranked.map((p) => p.uid),
        ...forcedOut.map((p) => p.uid),
      ],
    };
  },
};
