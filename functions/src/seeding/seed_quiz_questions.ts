import {getFirestore} from "firebase-admin/firestore";
import {
  initializeApp,
  cert,
  ServiceAccount,
} from "firebase-admin/app";
import serviceAccount from "../../serviceAccountKey.json";
import {
  CONFIG_COLLECTION,
  QUIZ_POOL_SEASONS_CONFIG_DOC,
  QUIZ_QUESTION_POOLS_COLLECTION,
  QuizPoolSeasonsConfigDoc,
  QuizQuestionDoc,
} from "../tournament/tournament_types";

import {QUICK_TRIVIA_QUESTIONS} from "./data/quick_trivia_questions";
import {TRUE_OR_FALSE_QUESTIONS} from "./data/true_or_false_questions";

initializeApp({
  credential: cert(serviceAccount as ServiceAccount),
  projectId: "gawla-19",
});

const db = getFirestore();

const SEASON_ID = "season_1";

const QUICK_TRIVIA_POOL_ID = "quick_trivia";
const TRUE_OR_FALSE_POOL_ID = "true_or_false";

/**
 * Seeds all quiz content for the current season.
 *
 * The seed is idempotent: deterministic document IDs are used so
 * running the script multiple times updates the same documents instead
 * of creating duplicates.
 *
 * @return {Promise<void>} Resolves when all quiz data is seeded.
 */
async function seedQuizQuestions(): Promise<void> {
  console.log("Starting quiz seed...");
  console.log(`Season: ${SEASON_ID}`);

  validateQuestions(
    QUICK_TRIVIA_QUESTIONS,
    QUICK_TRIVIA_POOL_ID,
    4,
  );

  validateQuestions(
    TRUE_OR_FALSE_QUESTIONS,
    TRUE_OR_FALSE_POOL_ID,
    2,
  );

  // ─────────────────────────────────────────────────────────────────────────
  // 1. Configure active seasons
  // ─────────────────────────────────────────────────────────────────────────

  const seasonConfig: QuizPoolSeasonsConfigDoc = {
    [QUICK_TRIVIA_POOL_ID]: SEASON_ID,
    [TRUE_OR_FALSE_POOL_ID]: SEASON_ID,
  };

  await db
    .collection(CONFIG_COLLECTION)
    .doc(QUIZ_POOL_SEASONS_CONFIG_DOC)
    .set(seasonConfig, {merge: true});

  console.log(
    `✓ Active seasons configured: ${JSON.stringify(seasonConfig)}`,
  );

  // ─────────────────────────────────────────────────────────────────────────
  // 2. Seed questions
  // ─────────────────────────────────────────────────────────────────────────

  const questionsToSeed: Array<{
    poolId: string;
    questions: QuizQuestionDoc[];
  }> = [
    {
      poolId: QUICK_TRIVIA_POOL_ID,
      questions: QUICK_TRIVIA_QUESTIONS,
    },
    {
      poolId: TRUE_OR_FALSE_POOL_ID,
      questions: TRUE_OR_FALSE_QUESTIONS,
    },
  ];

  const batch = db.batch();

  let totalQuestions = 0;

  for (const pool of questionsToSeed) {
    pool.questions.forEach((question, index) => {
      const questionId =
        `${pool.poolId}_${SEASON_ID}_${String(index + 1).padStart(3, "0")}`;

      const questionRef = db
        .collection(QUIZ_QUESTION_POOLS_COLLECTION)
        .doc(questionId);

      batch.set(
        questionRef,
        {
          ...question,
          seasonId: SEASON_ID,
        },
        {merge: true},
      );

      totalQuestions++;
    });
  }

  await batch.commit();

  console.log(
    `✓ Seeded ${totalQuestions} questions successfully.`,
  );

  console.log(
    `  - ${QUICK_TRIVIA_QUESTIONS.length} Quick Trivia`,
  );

  console.log(
    `  - ${TRUE_OR_FALSE_QUESTIONS.length} True or False`,
  );

  console.log("Quiz seed completed successfully.");
}

/**
 * Validates a question pool before writing it to Firestore.
 *
 * @param {QuizQuestionDoc[]} questions Questions to validate.
 * @param {string} poolId Pool identifier.
 * @param {number} expectedOptionsCount Expected number of options.
 * @return {void} Throws when the pool contains invalid data.
 */
function validateQuestions(
  questions: QuizQuestionDoc[],
  poolId: string,
  expectedOptionsCount: number,
): void {
  if (questions.length !== 50) {
    throw new Error(
      `${poolId}: expected exactly 50 questions, ` +
      `but found ${questions.length}.`,
    );
  }

  questions.forEach((question, index) => {
    const number = index + 1;

    if (!question.prompt.trim()) {
      throw new Error(
        `${poolId} question ${number}: prompt is empty.`,
      );
    }

    if (question.options.length !== expectedOptionsCount) {
      throw new Error(
        `${poolId} question ${number}: expected ` +
        `${expectedOptionsCount} options, got ${question.options.length}.`,
      );
    }

    if (
      question.correctIndex < 0 ||
      question.correctIndex >= question.options.length
    ) {
      throw new Error(
        `${poolId} question ${number}: invalid correctIndex ` +
        `${question.correctIndex}.`,
      );
    }

    if (question.seasonId !== SEASON_ID) {
      throw new Error(
        `${poolId} question ${number}: expected seasonId ` +
        `"${SEASON_ID}", got "${question.seasonId}".`,
      );
    }
  });
}

seedQuizQuestions()
  .then(() => {
    process.exit(0);
  })
  .catch((error: unknown) => {
    console.error("Quiz seed failed:", error);
    process.exit(1);
  });
