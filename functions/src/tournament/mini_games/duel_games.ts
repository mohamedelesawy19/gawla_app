import {MiniGameDefinition} from "./mini_game_definition";

type Choice = "rock" | "paper" | "scissors";
const VALID_CHOICES: Choice[] = ["rock", "paper", "scissors"];
// What each choice beats.
const BEATS: Record<Choice, Choice> = {
  rock: "scissors",
  paper: "rock",
  scissors: "paper",
};

/**
 * Reads and validates an RPS choice from the duel payload.
 *
 * @param {Record<string, unknown>} payload Submitted duel payload.
 * @return {Choice | null} Parsed choice or null when invalid.
 */
function readChoice(payload: Record<string, unknown>): Choice | null {
  const c = payload.choice;
  return typeof c === "string" && VALID_CHOICES.includes(c as Choice) ?
    (c as Choice) :
    null;
}

/**
 * Odd One Out (`MINI_GAMES_LIBRARY.md §4.6`): implemented as the doc's
 * offered "Rock-Paper-Scissors-style" variant rather than raw odd/even,
 * since RPS has an unambiguous win table — every pair of distinct choices
 * has a clear winner, and equal choices are a clean tie — which is easy to
 * validate and easy to build a reveal animation around.
 *
 * `resolveDuel` (not `normalize`) is what actually decides the winner —
 * see `mini_game_definition.ts`'s doc comment on why duels need a separate
 * relative-comparison hook instead of an absolute score.
 */
const oddOneOutDefinition: MiniGameDefinition = {
  isPlausible: (payload) => readChoice(payload) !== null,
  // Duels don't resolve through `normalize` at all — `resolveDuel` is
  // used instead (see `submit_round_result.ts`). This still needs to
  // exist to satisfy the interface; it's never called for this game.
  normalize: () => ({score: null, passed: null}),
  resolveDuel: (payloadA, payloadB) => {
    const a = readChoice(payloadA);
    const b = readChoice(payloadB);
    if (a === null || b === null) {
      return "tie"; // shouldn't happen post-validation
    }
    if (a === b) return "tie";
    return BEATS[a] === b ? "a" : "b";
  },
};

export const DUEL_GAME_DEFINITIONS: Record<string, MiniGameDefinition> = {
  odd_one_out: oddOneOutDefinition,
};
