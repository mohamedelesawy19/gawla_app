import {binaryFailStrategy} from "./binary_fail_strategy";
import {EliminationStrategy} from "./elimination_strategy";

/**
 * Survival Timer elimination (`MINI_GAMES_LIBRARY.md §1`, e.g. Steady
 * Hands): "maintain a state for the full duration; failing at any point =
 * out". By the time a round closes, that's already resolved to a single
 * `passed` boolean per player (see `mini_games/survival_games.ts`'s
 * cumulative-time-outside-zone check) — identical shape to `binaryFail`'s
 * resolve step, so this delegates rather than duplicating the logic.
 *
 * Kept as a distinct `EliminationType`/file (not merged into `binaryFail`)
 * because the two are semantically different triggers — a single wrong
 * action vs. a continuously-monitored state — and are likely to diverge
 * later (e.g. survival games gaining a partial-credit "grace budget"
 * instead of a hard threshold). Splitting them now means that divergence
 * won't require reclassifying every existing binaryFail game.
 */
export const survivalFailStrategy: EliminationStrategy = binaryFailStrategy;
