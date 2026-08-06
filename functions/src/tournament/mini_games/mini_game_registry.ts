import {BINARY_FAIL_GAME_DEFINITIONS} from "./binary_fail_games";
import {DUEL_GAME_DEFINITIONS} from "./duel_games";
import {MiniGameDefinition, num} from "./mini_game_definition";
import {SCORED_GAME_DEFINITIONS} from "./scored_games";
import {SURVIVAL_GAME_DEFINITIONS} from "./survival_games";
import {TEAM_GAME_DEFINITIONS} from "./team_games";

const ALL_DEFINITIONS: Record<string, MiniGameDefinition> = {
  ...SCORED_GAME_DEFINITIONS,
  ...BINARY_FAIL_GAME_DEFINITIONS,
  ...SURVIVAL_GAME_DEFINITIONS,
  ...TEAM_GAME_DEFINITIONS,
  ...DUEL_GAME_DEFINITIONS,
};

// Used for any `gameId` not yet registered above, so a brand-new mini-game
// doesn't hard-fail submissions before its real definition is written —
// best-effort guess based on whichever known field shows up in the
// payload. Mirrors the original `tournament_scoring.ts`'s `genericRule`.
const genericDefinition: MiniGameDefinition = {
  isPlausible: () => true,
  normalize: (payload) => {
    const score = num(payload, "score");
    if (score !== null) return {score, passed: null};

    const correct = num(payload, "correctAnswers");
    if (correct !== null) {
      return {
        score: correct * 1_000_000 - (num(payload, "totalTimeMs") ?? 0),
        passed: null,
      };
    }

    const reactionMs = num(payload, "reactionTimeMs");
    if (reactionMs !== null) return {score: -reactionMs, passed: null};

    const passed = payload.passed;
    if (typeof passed === "boolean") return {score: null, passed};

    return {score: null, passed: null}; // truly unrecognized payload shape
  },
};

/**
 * Returns the definition for a mini-game id, or the generic fallback.
 * Adding a real mini-game means adding one entry to one of the category
 * files above (or a new category file for a new elimination type) — this
 * function and every caller of it stay unchanged.
 *
 * @param {string} gameId The mini-game identifier.
 * @return {MiniGameDefinition} The definition for the id, or a fallback.
 */
export function getMiniGameDefinition(gameId: string): MiniGameDefinition {
  return ALL_DEFINITIONS[gameId] ?? genericDefinition;
}
