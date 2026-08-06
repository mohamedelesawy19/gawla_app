import {MiniGameDefinition, num} from "./mini_game_definition";

/**
 * Tug of Power (`MINI_GAMES_LIBRARY.md §4.7`): tap-rate aggregated into a
 * team total. `score` here is each player's individual contribution
 * (tap count) — `teamLossStrategy` sums it per team to find the losing
 * side, and reuses the same number to rank "weakest contributors" when a
 * round is configured for that mode instead of whole-team elimination.
 *
 * Anti-cheat: hard per-user tap-rate cap enforced here, scaled to the
 * round's own duration rather than a fixed number, so it stays correct if
 * `roundDurationSec` is tuned via Remote Config.
 *
 * Exported so `mini_games/tug_of_power/drive_tug_of_power_round.ts` (the
 * RTDB-side driver for the *live* team-power channel) can reuse the same
 * cap instead of a second hardcoded number drifting out of sync with it.
**/
export const MAX_TAPS_PER_SECOND = 12;

const tugOfPowerDefinition: MiniGameDefinition = {
  isPlausible: (payload) => {
    const taps = num(payload, "tapCount");
    const durationMs = num(payload, "roundDurationMs");
    if (taps === null || taps < 0) return false;
    if (durationMs === null || durationMs <= 0) return false;
    const maxPlausible = (durationMs / 1000) * MAX_TAPS_PER_SECOND;
    return taps <= maxPlausible;
  },
  normalize: (payload) => ({
    score: num(payload, "tapCount"),
    passed: null,
  }),
};

export const TEAM_GAME_DEFINITIONS: Record<string, MiniGameDefinition> = {
  tug_of_power: tugOfPowerDefinition,
};
