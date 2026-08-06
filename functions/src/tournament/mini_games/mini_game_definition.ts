/**
 * One implementation per mini-game id. This is the ONLY place that needs
 * to know what a given mini-game's raw `payload` (`MiniGameResult.
 * rawMetric` in `MINI_GAMES_LIBRARY.md §2` — reaction ms, correct-answer
 * count, tap count, ...) means. Everything downstream — the elimination
 * strategies — only ever sees the normalized `{score, passed}` shape (or,
 * for duels, a resolved winner), never the raw payload. That boundary is
 * what keeps `EliminationStrategy` implementations generic across every
 * mini-game that shares an elimination type.
 */
export interface MiniGameDefinition {
  /** MVP anti-cheat plausibility check (see `PROJECT_OVERVIEW.md`'s
   * anti-cheat table). An implausible payload normalizes to a voided
   * result rather than being rejected outright — it still counts as this
   * round's worst outcome for the player, per the original design. */
  isPlausible(payload: Record<string, unknown>): boolean;

  /** Normalizes a payload already confirmed plausible. `score` is used by
   * `rankCutoff`/`teamLoss`; `passed` is used by `binaryFail`/
   * `survivalFail`/`duelLoser`. A definition only needs to populate
   * whichever field its game's configured elimination type actually
   * reads — the other can stay `null`. */
  normalize(payload: Record<string, unknown>): {
    score: number | null;
    passed: boolean | null;
  };

  /**
   * Only implemented by duel-style games (`odd_one_out`). Given both
   * duelists' already-validated raw payloads, decides the winner. Kept
   * separate from `normalize` because a duel's outcome is inherently
   * relative — rock beats scissors, not a standalone score — unlike every
   * other elimination type, which resolves each player independently. See
   * `duel_games.ts` and `submit_round_result.ts`'s eager pairwise
   * resolution for how this gets called.
   */
  resolveDuel?(
    payloadA: Record<string, unknown>,
    payloadB: Record<string, unknown>,
  ): "a" | "b" | "tie";
}

/**
 * Reads a finite numeric field from a payload, or `null` if missing/
 * malformed. Shared by every definition below.
 *
 * @param {Record<string, unknown>} payload The payload to read from.
 * @param {string} key The payload key to inspect.
 * @return {number | null} The numeric value, or `null` when absent.
 */
export function num(
  payload: Record<string, unknown>,
  key: string,
): number | null {
  const v = payload[key];
  return typeof v === "number" && Number.isFinite(v) ? v : null;
}

/**
 * Reads a boolean field from a payload, or `null` if missing/malformed.
 *
 * @param {Record<string, unknown>} payload The payload to read from.
 * @param {string} key The payload key to inspect.
 * @return {boolean | null} The boolean value, or `null` when absent.
 */
export function bool(
  payload: Record<string, unknown>,
  key: string,
): boolean | null {
  const v = payload[key];
  return typeof v === "boolean" ? v : null;
}
