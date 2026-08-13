import {getFunctions} from "firebase-admin/functions";
import {logger} from "firebase-functions/v2";
import {BOT_FILL_QUEUE_FUNCTION} from "./bot_constants";

export interface BotFillTaskPayload {
  roomId: string;
  sequence: number;
}

/**
 * Schedules the next `fillRoomWithBot` dispatch for a room, `delaySeconds`
 * from now. This — not `onSchedule` — is what gives per-room bot adds a
 * true 15-30s cadence: Cloud Scheduler's own cron strings bottom out at
 * one-minute granularity (see `advanceStaleTournamentRounds`'s "every 1
 * minutes"), which is both too coarse for this requirement and would mean
 * scanning every waiting room on every tick forever, for the lifetime of
 * the app, even when no room is close to eligible. A self-rescheduling
 * Cloud Task instead exists only for as long as a specific room is
 * actually waiting and under capacity, and costs nothing otherwise — the
 * chain naturally stops the moment `fillRoomWithBot` sees the room is no
 * longer eligible (see that file).
 *
 * @param {BotFillTaskPayload} payload Which room/slot this task is for.
 * @param {number} delaySeconds How long from now to run it.
 * @return {Promise<void>} Resolves once the task is queued (or the queue
 * confirms an equivalent one is already in flight).
 */
export async function enqueueBotFillTask(
  payload: BotFillTaskPayload,
  delaySeconds: number,
): Promise<void> {
  const queue = getFunctions().taskQueue<BotFillTaskPayload>(
    BOT_FILL_QUEUE_FUNCTION,
  );

  try {
    await queue.enqueue(payload, {
      scheduleDelaySeconds: delaySeconds,
      // A deterministic task id lets Cloud Tasks itself de-dupe two
      // schedulers racing to queue the same next slot (both `fillRoomWith
      // Bot` retries and `onDocumentCreated`/task-handler races can both
      // legitimately try to enqueue "slot N" more than once). If the
      // deployed `firebase-admin` version doesn't support the `id`
      // option, this is a no-op optimization, not a safety requirement —
      // correctness (never two bots for the same slot, never exceeding
      // capacity) is already guaranteed independently by the deterministic
      // bot uid + Firestore transaction inside `fillRoomWithBot`.
      id: `bot-fill--${payload.roomId}--${payload.sequence}`,
    });
  } catch (err) {
    logger.warn("bots: failed to enqueue bot-fill task", {
      roomId: payload.roomId,
      sequence: payload.sequence,
      err,
    });
  }
}
