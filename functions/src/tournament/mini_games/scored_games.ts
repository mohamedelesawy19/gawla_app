import {MiniGameDefinition, num} from "./mini_game_definition";

/**
 * Reflex-style games (Reaction Tap, Color Challenge, Musical Freeze): lower
 * time is better. Direct port of the original `reflexRule` from
 * `tournament_scoring.ts` — `PROJECT_OVERVIEW.md` explicitly calls out
 * <100ms as implausible for a real human tap; 120ms leaves a small margin
 * before auto-voiding.
 *
 * `passed` is set to `false` (a forced elimination, not just a low score)
 * for the false-start case — tapping before the trigger, or arriving
 * before the stop event — which `rankCutoffStrategy` always cuts
 * regardless of the round's percentage target, per `MINI_GAMES_LIBRARY.md
 * §4.3`'s "false starts always cut regardless of rank".
 */
const reflexDefinition: MiniGameDefinition = {
  isPlausible: (payload) => {
    if (bool(payload, "falseStart") === true) {
      // Still a valid submission, just a forced loss.
      return true;
    }
    const t = num(payload, "reactionTimeMs");
    return t !== null && t >= 120 && t <= 10_000;
  },
  normalize: (payload) => {
    if (bool(payload, "falseStart") === true) {
      return {score: null, passed: false};
    }
    const t = num(payload, "reactionTimeMs");
    return {score: t === null ? null : -t, passed: null};
  },
};

/**
 * Reads a boolean from payload, returning null when absent or malformed.
 *
 * @param {Record<string, unknown>} payload Payload to read from.
 * @param {string} key Property key.
 * @return {boolean | null} Parsed boolean value.
 */
function bool(payload: Record<string, unknown>, key: string): boolean | null {
  const v = payload[key];
  return typeof v === "boolean" ? v : null;
}

/**
 * Knowledge/accuracy games (Trivia, Math Rush, Memory, Sequence, Find the
 * Difference, Hidden Object, True/False, Speed Typing): correctness
 * dominates, speed is only a tiebreaker. Direct port of the original
 * `accuracyRule`.
 */
const accuracyDefinition: MiniGameDefinition = {
  isPlausible: (payload) => {
    const correct = num(payload, "correctAnswers");
    const totalTime = num(payload, "totalTimeMs");
    return correct !== null && correct >= 0 &&
      totalTime !== null && totalTime >= 0;
  },
  normalize: (payload) => {
    const correct = num(payload, "correctAnswers");
    if (correct === null) return {score: null, passed: null};
    const totalTime = num(payload, "totalTimeMs") ?? 0;
    return {score: correct * 1_000_000 - totalTime, passed: null};
  },
};

export const SCORED_GAME_DEFINITIONS: Record<string, MiniGameDefinition> = {
  reaction_tap: reflexDefinition,
  color_challenge: reflexDefinition,
  musical_freeze: reflexDefinition,
  quick_trivia: accuracyDefinition,
  true_or_false: accuracyDefinition,
  math_rush: accuracyDefinition,
  memory_cards: accuracyDefinition,
  sequence_order: accuracyDefinition,
  find_the_difference: accuracyDefinition,
  hidden_object: accuracyDefinition,
  speed_typing: accuracyDefinition,
};
