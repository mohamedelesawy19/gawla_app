import {HttpsError, onCall} from "firebase-functions/v2/https";
import {
  CONFIG_COLLECTION,
  QUIZ_POOL_SEASONS_CONFIG_DOC,
  QUIZ_QUESTION_POOLS_COLLECTION,
  QuizPoolSeasonsConfigDoc,
  QuizQuestionDoc,
} from "../../tournament_types";
import {db} from "../../../shared/firestore";

/**
 * Hard ceiling on how many questions a single call can return, independent
 * of whatever `count` the client asks for — stops one call from scraping
 * an entire season's pool. `QuestionFlowGameWidget`'s `questionCount`
 * defaults to 3 and Math Rush doesn't call this at all, so this is
 * generous headroom for legitimate use, not a real limit.
 */
const MAX_QUESTIONS_PER_CALL = 10;

/**
 * Which pools this function is allowed to serve. Deliberately an allowlist
 * (not "any string the client sends") so a malformed/guessed poolId fails
 * loudly instead of silently returning an empty batch.
 */
const ALLOWED_POOL_IDS = new Set(["quick_trivia", "true_or_false"]);

// Simple in-memory TTL cache for the season pointer — mirrors
// `mini_game_catalog.ts`'s caching approach, avoiding a Firestore read on
// every single call. A season pointer is expected to change rarely (by
// design — a season can run for months), so a short staleness window here
// has no real gameplay consequence.
const seasonCache = new Map<
  string,
  {seasonId: string; expiresAt: number}
>();

const SEASON_CACHE_TTL_MS = 5 * 60_000;

/**
 * Resolves the currently active season id for a pool by reading the
 * centralized `config/quizPoolSeasons` document. The season id is
 * deliberately NOT computed from any date-based formula. A Gawla
 * season has no fixed length, so this function does not assume any
 * cadence; content management changes the configured season id
 * whenever the active season changes.
 *
 * @param {string} poolId Which pool to resolve the active season for.
 * @return {Promise<string>} The pool's current season id.
 */
async function currentSeasonId(poolId: string): Promise<string> {
  const cached = seasonCache.get(poolId);

  if (cached && cached.expiresAt > Date.now()) {
    return cached.seasonId;
  }

  const doc = await db
    .collection(CONFIG_COLLECTION)
    .doc(QUIZ_POOL_SEASONS_CONFIG_DOC)
    .get();

  if (!doc.exists) {
    throw new HttpsError(
      "failed-precondition",
      "Quiz pool seasons configuration is missing.",
    );
  }

  const config = doc.data() as QuizPoolSeasonsConfigDoc;
  const seasonId = config[poolId];

  if (typeof seasonId !== "string" || seasonId.trim().length === 0) {
    throw new HttpsError(
      "failed-precondition",
      `No active season configured for pool "${poolId}".`,
    );
  }

  seasonCache.set(poolId, {
    seasonId,
    expiresAt: Date.now() + SEASON_CACHE_TTL_MS,
  });

  return seasonId;
}

/**
 * Serves this round's question batch for Quick Trivia / True-or-False.
 * This is the ONLY sanctioned way a player's device ever sees a question
 * from `QUIZ_QUESTION_POOLS_COLLECTION` — the pool itself is never shipped
 * in the client build, per `MINI_GAMES_LIBRARY.md §3.2`'s anti-cheat note,
 * and each call only returns a small random slice, not the full pool.
 *
 * Math Rush does NOT go through this — `ProceduralMathQuestionSource`
 * generates its questions entirely on-device, so it has no corresponding
 * backend piece at all.
 */
export const fetchQuizPool = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Sign-in required.");
  }

  const poolId = request.data?.poolId;

  if (
    typeof poolId !== "string" ||
    !ALLOWED_POOL_IDS.has(poolId)
  ) {
    throw new HttpsError("invalid-argument", "Unknown poolId.");
  }

  const rawCount = request.data?.count;

  const count = Math.min(
    MAX_QUESTIONS_PER_CALL,
    typeof rawCount === "number" && Number.isFinite(rawCount) ?
      Math.max(1, Math.floor(rawCount)) :
      3,
  );

  const seasonId = await currentSeasonId(poolId);

  const snapshot = await db
    .collection(QUIZ_QUESTION_POOLS_COLLECTION)
    .where("seasonId", "==", seasonId)
    .get();

  if (snapshot.empty) {
    throw new HttpsError(
      "failed-precondition",
      `No questions seeded for "${poolId}"'s active season (${seasonId}).`,
    );
  }

  const pool = snapshot.docs.map(
    (doc) => doc.data() as QuizQuestionDoc,
  );

  const questions = shuffle(pool)
    .slice(0, count)
    .map((q) => ({
      prompt: q.prompt,
      options: q.options,
      correctIndex: q.correctIndex,
    }));

  return {questions};
});

/**
 * Fisher-Yates shuffle, in place.
 *
 * @param {T[]} items Array to shuffle.
 * @return {T[]} The same array, shuffled.
 */
function shuffle<T>(items: T[]): T[] {
  for (let i = items.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [items[i], items[j]] = [items[j], items[i]];
  }

  return items;
}
