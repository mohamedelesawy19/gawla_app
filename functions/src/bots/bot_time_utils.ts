/**
 * Resolves after the specified delay. Mirrors the identically-named
 * helper in `drive_freeze_frenzy_round.ts` — kept as its own copy here
 * (rather than exported/shared) since these live in different domains
 * (`bots/` vs `tournament/mini_games/`) and the README's cross-domain
 * import rule keeps sharing to explicit, narrow interfaces.
 *
 * @param {number} ms Delay in milliseconds.
 * @return {Promise<void>} A promise that resolves after the delay.
 */
export function sleep(ms: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, Math.max(0, ms)));
}

/**
 * Returns a random integer within the inclusive range.
 *
 * @param {number} minInclusive Minimum possible value.
 * @param {number} maxInclusive Maximum possible value.
 * @return {number} A random integer within the inclusive range.
 */
export function randomBetween(
  minInclusive: number,
  maxInclusive: number
): number {
  return Math.floor(
    minInclusive + Math.random() * (maxInclusive - minInclusive + 1),
  );
}
