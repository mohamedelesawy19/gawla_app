import {
  EliminationTargetDoc,
  MIN_SURVIVORS_PER_ROUND,
} from "../tournament_types";

/**
 * Turns a count-or-percentage `EliminationTarget` into a concrete number of
 * players to cut from a pool of `poolSize`, always leaving at least
 * `MIN_SURVIVORS_PER_ROUND` behind. Shared by any strategy that needs a
 * target-driven cut count (`rankCutoff`, and `teamLoss` in its
 * weakest-contributors mode).
 *
 * @param {EliminationTargetDoc | null} target The round's configured
 * target, or `null` to fall back to `defaultFraction`.
 * @param {number} poolSize Number of players the target applies to.
 * @param {number} defaultFraction Fraction used when `target` is `null`.
 * @return {number} Concrete elimination count, clamped so at least
 * `MIN_SURVIVORS_PER_ROUND` players remain.
 */
export function resolveEliminationCount(
  target: EliminationTargetDoc | null,
  poolSize: number,
  defaultFraction = 0.35,
): number {
  const raw = target === null ?
    poolSize * defaultFraction :
    target.kind === "count" ?
      target.value :
      poolSize * target.value;

  const maxCuttable = Math.max(0, poolSize - MIN_SURVIVORS_PER_ROUND);
  return Math.max(0, Math.min(maxCuttable, Math.round(raw)));
}
