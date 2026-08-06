import {EliminationType} from "../tournament_types";
import {binaryFailStrategy} from "./binary_fail_strategy";
import {compositeFinalStrategy} from "./composite_final_strategy";
import {duelLoserStrategy} from "./duel_loser_strategy";
import {EliminationStrategy} from "./elimination_strategy";
import {rankCutoffStrategy} from "./rank_cutoff_strategy";
import {survivalFailStrategy} from "./survival_fail_strategy";
import {teamLossStrategy} from "./team_loss_strategy";

const STRATEGIES: Record<EliminationType, EliminationStrategy> = {
  rankCutoff: rankCutoffStrategy,
  binaryFail: binaryFailStrategy,
  duelLoser: duelLoserStrategy,
  survivalFail: survivalFailStrategy,
  teamLoss: teamLossStrategy,
  compositeFinal: compositeFinalStrategy,
};

/**
 * Single lookup point `tournament_round_closer.ts` uses to stay
 * elimination-type-agnostic. Adding a 7th `EliminationType` means adding
 * one entry here (plus the enum member in `tournament_types.ts` and its
 * Dart mirror) — nothing else in the Tournament feature changes.
 *
 * @param {EliminationType} type The round's configured elimination type.
 * @return {EliminationStrategy} The matching strategy implementation.
 */
export function getEliminationStrategy(
  type: EliminationType,
): EliminationStrategy {
  return STRATEGIES[type];
}
