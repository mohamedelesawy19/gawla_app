/**
 * Bot identity is deliberately NOT a new field on any Firestore document.
 * A bot is just an ordinary room/tournament player whose `uid` happens to
 * start with `BOT_UID_PREFIX` — every existing read path (`RoomModel`,
 * `TournamentModel`, `parseRoomSnapshot`, every `EliminationStrategy`,
 * every `MiniGameDefinition`) keeps working unmodified, and no Firestore
 * security rule or Dart model needs to special-case a new shape.
 *
 * `uid`s are never backed by a real Firebase Auth account, which is also
 * exactly why bots can never authenticate through `submitRoundResult`'s
 * `onCall` entry point — see `applyRoundResult` in
 * `../tournament/submit_round_result.ts` for how bot code calls the same
 * validation/elimination path as a human without a client identity.
 */
export const BOT_UID_PREFIX = "bot_";

/**
 * @param {string} uid A room/tournament player id.
 * @return {boolean} Whether `uid` identifies a bot.
 */
export function isBotUid(uid: string): boolean {
  return uid.startsWith(BOT_UID_PREFIX);
}

/**
 * Deterministic uid for the Nth bot added to a room. Determinism (rather
 * than a random id generated fresh on every attempt) is what makes
 * `fillRoomWithBot` safe to retry: a retried/duplicated task recomputes
 * the exact same uid, so the add transaction can recognize "I already did
 * this" instead of creating a second bot for the same slot.
 *
 * @param {string} roomId Room the bot is being added to.
 * @param {number} sequence 1-based slot number within the room (the Nth
 * bot-fill task for this room).
 * @return {string} A stable, collision-free bot uid.
 */
export function botUidForSlot(roomId: string, sequence: number): string {
  return `${BOT_UID_PREFIX}${roomId}_${sequence}`;
}

export interface BotProfile {
  uid: string;
  displayName: string;
  avatarUrl: string | null;
}

// Deliberately generic/playful, no trademarked or real-person names.
const BOT_NAME_POOL: readonly string[] = [
  "Nova", "Blaze", "Comet", "Pixel", "Turbo", "Echo", "Nimbus", "Orbit",
  "Volt", "Cinder", "Drift", "Rally", "Zephyr", "Quartz", "Static",
  "Glimmer", "Rocket", "Fable", "Piston", "Shard", "Tango", "Vertex",
  "Wisp", "Ember", "Frost", "Karma", "Lumen", "Marble", "Onyx", "Ripple",
];

/**
 * FNV-1a — small, dependency-free, and stable across Node versions, which
 * is all "give me a deterministic pseudo-random number from a string"
 * needs here (no cryptographic property required; bots aren't a security
 * boundary).
 *
 * @param {string} value String to hash.
 * @return {number} A 32-bit unsigned hash of `value`.
 */
function hashString(value: string): number {
  let hash = 0x811c9dc5;
  for (let i = 0; i < value.length; i++) {
    hash ^= value.charCodeAt(i);
    hash = Math.imul(hash, 0x01000193);
  }
  return hash >>> 0;
}

/**
 * Builds a stable display identity for a bot from its uid alone, so no
 * extra Firestore write/read is needed to remember "which name did this
 * bot get" — recomputing it is always the same computation.
 *
 * @param {string} uid The bot's uid (see `botUidForSlot`).
 * @return {BotProfile} Display name + avatar for the room player entry.
 */
export function generateBotProfile(uid: string): BotProfile {
  const nameHash = hashString(uid);
  const name = BOT_NAME_POOL[nameHash % BOT_NAME_POOL.length];
  const suffix = 100 + (hashString(`${uid}#suffix`) % 900);
  return {
    uid,
    displayName: `${name} #${suffix}`,
    // No bot avatar asset is part of this changeset - `null` renders
    // through the same "no avatar" placeholder path every human without
    // a profile photo already goes through.
    avatarUrl: null,
  };
}

/**
 * Deterministic pseudo-random "skill" in `[0, 1)` for a bot, scoped by
 * `salt` (typically `${tournamentId}:${roundIndex}:${gameId}`) so the
 * same bot isn't uncannily identical (always-best or always-worst) in
 * every round — it plays a little differently each time, like a human's
 * inconsistent performance, while still being a pure function of its
 * inputs (no extra state to store or race).
 *
 * @param {string} uid The bot's uid.
 * @param {string} salt Extra scoping input (round/game context).
 * @return {number} A value in `[0, 1)`.
 */
export function botSkill(uid: string, salt: string): number {
  return (hashString(`${uid}::${salt}`) % 10_000) / 10_000;
}
