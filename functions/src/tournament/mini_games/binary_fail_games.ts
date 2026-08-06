import {MiniGameDefinition, num} from "./mini_game_definition";

/**
 * Freeze Frenzy (`MINI_GAMES_LIBRARY.md §4.1`): the real red/green timing
 * enforcement (grace-window check against the server-broadcast switch
 * timestamp) is a real-time concern the Mini Games feature owns via its
 * own low-latency channel, not something a single end-of-round payload can
 * express — see ARCHITECTURE_ANALYSIS.md's "Tournament only needs final
 * outcomes" principle. By the time this payload reaches `submitRoundResult`
 * it's already a finished summary: did they move during a RED window, and
 * did they reach the finish line before time ran out.
 */
const freezeFrenzyDefinition: MiniGameDefinition = {
  isPlausible: (payload) =>
    typeof payload.movedDuringRed === "boolean" &&
    typeof payload.reachedFinish === "boolean",
  normalize: (payload) => ({
    score: null,
    passed: payload.movedDuringRed === false && payload.reachedFinish === true,
  }),
};

/**
 * Tile Trap (`MINI_GAMES_LIBRARY.md §4.2`): each step's pick is validated
 * live against the server-held hidden safe-path (its own real-time
 * mechanic, outside this file's scope, same reasoning as Freeze Frenzy
 * above). This definition only consumes the finished summary.
 */
const tileTrapDefinition: MiniGameDefinition = {
  isPlausible: (payload) => typeof payload.reachedEnd === "boolean",
  normalize: (payload) => ({score: null, passed: payload.reachedEnd === true}),
};

/**
 * Trace the Shape (`MINI_GAMES_LIBRARY.md §4.5`): path is validated
 * server-side against the target vector shape as it's drawn; this
 * definition consumes the resulting completion percentage and tolerance-
 * breach count directly, since — unlike Freeze Frenzy/Tile Trap — those
 * two numbers are a reasonable one-shot summary rather than needing a
 * step-by-step channel.
 */
const REQUIRED_COMPLETION_PERCENT = 90;
const MAX_ALLOWED_BREACHES = 2;

const traceTheShapeDefinition: MiniGameDefinition = {
  isPlausible: (payload) => {
    const completion = num(payload, "completionPercent");
    const breaches = num(payload, "toleranceBreaches");
    return completion !== null && completion >= 0 && completion <= 100 &&
      breaches !== null && breaches >= 0;
  },
  normalize: (payload) => {
    const completion = num(payload, "completionPercent") ?? 0;
    const breaches =
      num(payload, "toleranceBreaches") ?? Number.MAX_SAFE_INTEGER;
    return {
      score: null,
      passed: completion >= REQUIRED_COMPLETION_PERCENT &&
        breaches <= MAX_ALLOWED_BREACHES,
    };
  },
};

export const BINARY_FAIL_GAME_DEFINITIONS:
Record<string, MiniGameDefinition> = {
  freeze_frenzy: freezeFrenzyDefinition,
  tile_trap: tileTrapDefinition,
  trace_the_shape: traceTheShapeDefinition,
};
