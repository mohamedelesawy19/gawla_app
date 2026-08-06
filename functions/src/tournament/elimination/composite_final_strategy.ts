import {MiniGameConfig} from "../tournament_types";
import {
  EliminationDecision,
  EliminationStrategy,
  RoundParticipant,
} from "./elimination_strategy";
import {rankCutoffStrategy} from "./rank_cutoff_strategy";

/**
 * Composite/Boss elimination (`MINI_GAMES_LIBRARY.md §1` and §4.8): the
 * finale, mixing two mechanics from mini-games already played, resolving
 * to a single winner.
 *
 * MVP SIMPLIFICATION — flagged deliberately rather than silently faked:
 * true composition ("engine picks 2 sub-mechanics sized to the finalist
 * count, reuses whichever anti-cheat pattern the sub-mechanics need") is a
 * meaningfully bigger feature — it needs a nested round-within-a-round
 * concept, since a Boss Round's two sub-mechanics could themselves be a
 * `rankCutoff` sprint and a `duelLoser` decider running in sequence. That's
 * a real follow-up, not something to hand-wave into this refactor.
 *
 * For now, `compositeFinal` behaves as `rankCutoff` with the target forced
 * to "all but 1" — i.e. a single ranked finale round, which satisfies
 * "resolves to a single winner" and lets `boss_round` slot into the
 * existing rotation today. Swapping in true composition later only means
 * replacing this file's `resolve` — the elimination-type contract and
 * everything upstream of it (round closer, catalog, Mini Games feature)
 * stays the same either way.
 */
export const compositeFinalStrategy: EliminationStrategy = {
  prepareGroups: () => null,

  resolve(
    participants: RoundParticipant[],
    config: MiniGameConfig,
  ): EliminationDecision {
    const forcedTarget = {
      kind: "count" as const,
      value: participants.length - 1,
    };
    return rankCutoffStrategy.resolve(participants, {
      ...config,
      eliminationTarget: forcedTarget,
    });
  },
};
