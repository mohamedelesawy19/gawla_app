import {getRemoteConfig} from "firebase-admin/remote-config";
import {
  EliminationTargetDoc,
  FALLBACK_ELIMINATION_FRACTION,
  FALLBACK_ROUND_DURATION_MS,
  MiniGameConfig,
} from "./tournament_types";

/**
 * Resolves `gameId -> MiniGameConfig` so round duration, elimination type,
 * and cut target can be tuned from Remote Config without an app release —
 * `PROJECT_OVERVIEW.md`'s "configuration-driven gameplay" requirement, and
 * the library doc's "generated/pulled from Remote Config or room settings"
 * note on `MiniGameConfig`.
 *
 * This is the ONLY place a mini-game id gets turned into round-scheduling
 * facts (duration, elimination type/target). `start_tournament.ts` and
 * `tournament_round_closer.ts` both go through this module rather than
 * hardcoding a duration or type anywhere themselves — that's the actual
 * fix for the old `DEFAULT_ROUND_DURATION_MS` / `ELIMINATION_FRACTION`
 * globals.
 *
 * Defaults below are transcribed from each mini-game's spec in
 * `MINI_GAMES_LIBRARY.md` (round duration ranges, elimination type) and are
 * what's used whenever Remote Config has no override yet, or is
 * unreachable — a Remote Config outage must never be able to prevent a
 * tournament from starting.
 */

const DEFAULTS: Record<string, MiniGameConfig> = {
  // Tier A
  reaction_tap: cfg("reaction_tap", 12, "rankCutoff", pct(0.4)),
  quick_trivia: cfg("quick_trivia", 30, "rankCutoff", pct(0.35)),
  memory_cards: cfg("memory_cards", 40, "rankCutoff", pct(0.35)),
  find_the_difference: cfg("find_the_difference", 45, "rankCutoff", pct(0.35)),
  color_challenge: cfg("color_challenge", 40, "rankCutoff", pct(0.35)),
  math_rush: cfg("math_rush", 40, "rankCutoff", pct(0.35)),
  // Library doc marks this one as configurable per round (binaryFail OR
  // rankCutoff) — defaulting to rankCutoff; override via Remote Config to
  // switch a specific tournament's rotation to binaryFail instead.
  sequence_order: cfg("sequence_order", 40, "rankCutoff", pct(0.35)),
  speed_typing: cfg("speed_typing", 25, "rankCutoff", pct(0.35)),
  true_or_false: cfg("true_or_false", 25, "rankCutoff", pct(0.35)),
  hidden_object: cfg("hidden_object", 45, "rankCutoff", pct(0.35)),
  // Tier B
  freeze_frenzy: cfg("freeze_frenzy", 55, "binaryFail", null),
  tile_trap: cfg("tile_trap", 75, "binaryFail", null),
  musical_freeze: cfg("musical_freeze", 40, "rankCutoff", pct(0.35)),
  steady_hands: cfg("steady_hands", 40, "survivalFail", null),
  trace_the_shape: cfg("trace_the_shape", 55, "binaryFail", null),
  odd_one_out: cfg("odd_one_out", 75, "duelLoser", null),
  // No target -> whole losing team eliminated (see team_loss_strategy.ts).
  // Set an override with a count target to switch to "weakest N cut" mode.
  tug_of_power: cfg("tug_of_power", 40, "teamLoss", null),
  boss_round: cfg("boss_round", 75, "compositeFinal", null),
};

/**
 * Creates a percentage-based elimination target.
 *
 * @param {number} value Fraction of players to eliminate (0..1).
 * @return {EliminationTargetDoc} Percentage elimination target.
 */
function pct(value: number): EliminationTargetDoc {
  return {kind: "percentage", value};
}

/**
 * Creates a complete mini-game configuration.
 *
 * @param {string} gameId Mini-game identifier.
 * @param {number} roundDurationSec Round duration in seconds.
 * @param {string} eliminationType
 * Elimination strategy for this mini-game.
 * @param {EliminationTargetDoc|null} eliminationTarget
 * Optional elimination target.
 * @return {MiniGameConfig} Complete configuration.
 */
function cfg(
  gameId: string,
  roundDurationSec: number,
  eliminationType: MiniGameConfig["eliminationType"],
  eliminationTarget: EliminationTargetDoc | null,
): MiniGameConfig {
  return {
    gameId,
    roundDurationSec,
    eliminationType,
    eliminationTarget,
    difficultyModifier: null,
  };
}

const genericFallback = (gameId: string): MiniGameConfig => ({
  gameId,
  roundDurationSec: Math.round(FALLBACK_ROUND_DURATION_MS / 1000),
  eliminationType: "rankCutoff",
  eliminationTarget: pct(FALLBACK_ELIMINATION_FRACTION),
  difficultyModifier: null,
});

// Simple in-memory TTL cache — a tournament's mini-game rotation is
// resolved once at `startTournament` time and again on each round
// activation, so this avoids a Remote Config fetch per round in a single
// tournament's lifetime without needing external caching infra.
let cachedTemplateParams: Record<string, unknown> | null = null;
let cacheFetchedAtMs = 0;
const CACHE_TTL_MS = 5 * 60_000;

/**
 * Loads mini-game overrides from Remote Config.
 *
 * @return {Promise<Record<string, unknown> | null>}
 * Cached or fetched overrides.
 */
async function loadCatalogParam(): Promise<Record<string, unknown> | null> {
  const now = Date.now();
  if (cachedTemplateParams && now - cacheFetchedAtMs < CACHE_TTL_MS) {
    return cachedTemplateParams;
  }
  try {
    const template = await getRemoteConfig().getServerTemplate();
    template.load();
    const raw = template.evaluate().getValue("miniGameCatalog").asString();
    cachedTemplateParams = raw ? JSON.parse(raw) : {};
    cacheFetchedAtMs = now;
    return cachedTemplateParams;
  } catch {
    // Remote Config unreachable / param missing / malformed JSON — fall
    // back to defaults rather than failing tournament start.
    return null;
  }
}

/**
 * Resolves the config for a single mini-game. `roundIndex` is accepted for
 * future difficulty scaling (e.g. shrinking `roundDurationSec` or raising
 * `difficultyModifier` on later rounds of the same game) but unused today —
 * kept in the signature so adding that scaling later doesn't ripple into
 * every call site.
 *
 * @param {string} gameId Mini-game identifier, matches
 * `MINI_GAMES_LIBRARY.md`'s ID column.
 * @param {number} roundIndex Position of this round within the tournament.
 * @return {Promise<MiniGameConfig>} The resolved config.
 */
export async function getMiniGameConfig(
  gameId: string,
  roundIndex: number,
): Promise<MiniGameConfig> {
  void roundIndex; // reserved for future difficulty scaling
  const overrides = await loadCatalogParam();
  const override = overrides?.[gameId] as Partial<MiniGameConfig> | undefined;
  const base = DEFAULTS[gameId] ?? genericFallback(gameId);
  return override ? {...base, ...override, gameId} : base;
}
