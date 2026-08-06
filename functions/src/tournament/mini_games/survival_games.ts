import {MiniGameDefinition, num} from "./mini_game_definition";

/**
 * Steady Hands (`MINI_GAMES_LIBRARY.md §4.4`): cumulative time outside the
 * shrinking zone, tracked client-side for responsiveness but summarized
 * and validated here. Threshold is 30% of the round's own duration, so it
 * scales automatically if `roundDurationSec` changes via Remote Config
 * rather than needing a second config value kept in sync by hand.
 */
const MAX_OUTSIDE_ZONE_FRACTION = 0.3;

const steadyHandsDefinition: MiniGameDefinition = {
  isPlausible: (payload) => {
    const outside = num(payload, "timeOutsideZoneMs");
    const total = num(payload, "roundDurationMs");
    return outside !== null && outside >= 0 &&
      total !== null && total > 0 && outside <= total;
  },
  normalize: (payload) => {
    const outside = num(payload, "timeOutsideZoneMs");
    const total = num(payload, "roundDurationMs");
    if (outside === null || total === null || total === 0) {
      return {score: null, passed: null};
    }
    return {score: null, passed: outside / total <= MAX_OUTSIDE_ZONE_FRACTION};
  },
};

export const SURVIVAL_GAME_DEFINITIONS: Record<string, MiniGameDefinition> = {
  steady_hands: steadyHandsDefinition,
};
