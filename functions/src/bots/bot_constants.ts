/**
 * Bot-fill cadence: at most one bot is added per room every 15-30s (a
 * random delay inside this window, re-rolled after every add) — see
 * `fillRoomWithBot`'s doc comment for why this is Cloud Tasks-driven
 * rather than a cron tick.
 */
export const MIN_BOT_FILL_DELAY_SECONDS = 15;
export const MAX_BOT_FILL_DELAY_SECONDS = 30;

/** Deployed function name of the Cloud Tasks target
 * — see `bot_fill_queue.ts`. */
export const BOT_FILL_QUEUE_FUNCTION = "fillRoomWithBot";

/**
 * Private, server-only subcollection used purely as an atomic "has a bot
 * driver already claimed this round" marker (`DocumentReference.create()`
 * fails if the doc exists, which is all the atomicity this needs — no
 * transaction required). Same rationale/requirement as
 * `DUEL_COMMITS_SUBCOLLECTION` in `tournament_types.ts`: this must never
 * be directly readable/writable by a client —
 * `match /tournaments/{id}/_botRoundClaims/{doc}
 * { allow read, write: if false; }`
 * needs to be added alongside this change.
 */
export const BOT_ROUND_CLAIMS_SUBCOLLECTION = "_botRoundClaims";
