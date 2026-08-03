/**
 * Per-mini-game scoring + plausibility rules.
 *
 * The client submits a raw, mini-game-specific `payload` (see
 * `SubmitRoundResultParams`'s doc comment on the Flutter side, e.g.
 * `{reactionTimeMs: 254}` or `{correctAnswers: 7, totalTimeMs: 9400}`).
 * This file is the ONLY place that needs to know what those keys mean —
 * everything downstream (ranking, elimination) just consumes a plain
 * number where HIGHER IS ALWAYS BETTER.
 *
 * `isPlausible` is the MVP version of the anti-cheat table in
 * PROJECT_OVERVIEW.md ("impossible results ... statistical outlier
 * detection ... auto-flag for review or auto-void"). This MVP auto-VOIDS
 * an implausible submission (score becomes null, so it ranks last and the
 * player is treated as this round's worst performer) rather than queuing
 * it for manual review — wire up a review queue later if you want a
 * softer path than instant elimination.
 *
 * NOTE: `miniGameId` keys below are placeholders based on the MVP mini-game
 * list in PROJECT_OVERVIEW.md. Swap in your real ids once the Mini Games
 * feature exists — anything not listed here falls back to `genericRule`.
 */

export interface MiniGameRule {
  /** Returns a comparable score (higher = better), or null if unparseable. */
  normalizedScore: (payload: Record<string, unknown>) => number | null;
  /** Rejects results that are physically/statistically impossible. */
  isPlausible: (payload: Record<string, unknown>) => boolean;
}

function num(payload: Record<string, unknown>, key: string): number | null {
  const v = payload[key];
  return typeof v === "number" && Number.isFinite(v) ? v : null;
}

// Reflex-style games (Reaction Tap, Color Challenge): lower time is better.
// PROJECT_OVERVIEW explicitly calls out <100ms as implausible for a real
// human tap; 120ms leaves a small margin before auto-voiding.
const reflexRule: MiniGameRule = {
  normalizedScore: (payload) => {
    const t = num(payload, "reactionTimeMs");
    return t === null ? null : -t;
  },
  isPlausible: (payload) => {
    const t = num(payload, "reactionTimeMs");
    return t !== null && t >= 120 && t <= 10_000;
  },
};

// Knowledge/accuracy games (Trivia, Math Rush, Memory, Sequence, Find the
// Difference, Hidden Object, True/False): correctness dominates, speed is
// only a tiebreaker.
const accuracyRule: MiniGameRule = {
  normalizedScore: (payload) => {
    const correct = num(payload, "correctAnswers");
    if (correct === null) return null;
    const totalTime = num(payload, "totalTimeMs") ?? 0;
    return correct * 1_000_000 - totalTime;
  },
  isPlausible: (payload) => {
    const correct = num(payload, "correctAnswers");
    const totalTime = num(payload, "totalTimeMs");
    return correct !== null && correct >= 0 && totalTime !== null && totalTime >= 0;
  },
};

export const MINI_GAME_RULES: Record<string, MiniGameRule> = {
  reaction_tap: reflexRule,
  color_challenge: reflexRule,
  quick_trivia: accuracyRule,
  true_or_false: accuracyRule,
  math_rush: accuracyRule,
  memory_cards: accuracyRule,
  sequence_order: accuracyRule,
  find_the_difference: accuracyRule,
  hidden_object: accuracyRule,
  speed_typing: accuracyRule,
};

// Used for any `miniGameId` not in the map above — best-effort guess based
// on whichever known field shows up in the payload, so a new mini-game
// doesn't hard-fail until you add a real rule for it.
const genericRule: MiniGameRule = {
  normalizedScore: (payload) => {
    const score = num(payload, "score");
    if (score !== null) return score;

    const correct = num(payload, "correctAnswers");
    if (correct !== null) return correct * 1_000_000 - (num(payload, "totalTimeMs") ?? 0);

    const t = num(payload, "reactionTimeMs");
    if (t !== null) return -t;

    return null; // truly unrecognized payload shape
  },
  isPlausible: () => true, // no game-specific bounds known yet — accept by default
};

export function getMiniGameRule(miniGameId: string): MiniGameRule {
  return MINI_GAME_RULES[miniGameId] ?? genericRule;
}
