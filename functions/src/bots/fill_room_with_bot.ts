import {FieldValue, Timestamp} from "firebase-admin/firestore";
import {onTaskDispatched} from "firebase-functions/v2/tasks";
import {logger} from "firebase-functions/v2";
import {db} from "../shared/firestore";
import {
  MAX_PLAYERS_PER_ROOM,
  ROOMS_COLLECTION,
  ROOM_STATUS_WAITING,
} from "../tournament/tournament_types";
import {
  MAX_BOT_FILL_DELAY_SECONDS,
  MIN_BOT_FILL_DELAY_SECONDS,
} from "./bot_constants";
import {enqueueBotFillTask, BotFillTaskPayload} from "./bot_fill_queue";
import {botUidForSlot, generateBotProfile} from "./bot_identity";
import {randomBetween} from "./bot_time_utils";

/**
 * Adds (at most) one bot to a waiting room, then — if the room is still
 * eligible — schedules the next bot-fill dispatch 15-30s from now. This
 * single-add-then-reschedule shape is what gives every room its own
 * independent ~15-30s cadence without a per-room timer/listener/process
 * having to stay alive the whole time a room is waiting: each dispatch
 * does a small amount of work and exits; nothing is "running" for a room
 * in between two dispatches (see `bot_fill_queue.ts`'s doc comment for why
 * `onSchedule` cron can't hit this cadence on its own).
 *
 * Every check that decides "should a bot be added / should the chain
 * continue" is re-evaluated from a fresh transactional read, so a human
 * joining, a host starting the tournament, another bot being added, or
 * this exact task being retried can never combine into more than
 * `MAX_PLAYERS_PER_ROOM` total players or two bots for the same slot —
 * see the inline comments below for each case.
 */
export const fillRoomWithBot = onTaskDispatched<BotFillTaskPayload>(
  {
    region: "europe-west6",
    retryConfig: {maxAttempts: 5, minBackoffSeconds: 5},
    rateLimits: {maxConcurrentDispatches: 25, maxDispatchesPerSecond: 10},
  },
  async (request) => {
    const {roomId, sequence} = request.data;

    if (!roomId || typeof roomId !== "string" ||
        !Number.isInteger(sequence) || sequence < 1) {
      logger.error("bots: malformed bot-fill task payload, dropping", {
        data: request.data,
      });
      return;
    }

    const roomRef = db.collection(ROOMS_COLLECTION).doc(roomId);
    // Deterministic per-slot uid: if this exact task is delivered twice
    // (Cloud Tasks is at-least-once), the second delivery will see this
    // uid already present in `players` and add nothing — see below.
    const botUid = botUidForSlot(roomId, sequence);

    const shouldRescheduleNext = await db.runTransaction(async (tx) => {
      const snap = await tx.get(roomRef);
      if (!snap.exists) {
        // Room closed/deleted (e.g. the last human left) — nothing to
        // fill, nothing to reschedule.
        return false;
      }

      const data = snap.data() as Record<string, unknown>;
      const status = data.status as string | undefined;
      const players = (data.players ?? {}) as Record<string, unknown>;
      const currentCount = Object.keys(players).length;

      if (status !== ROOM_STATUS_WAITING) {
        // Tournament already started, or the room otherwise left the
        // waiting state — bots stop being added immediately, and the
        // chain ends here. No explicit cancellation of any
        // already-scheduled next dispatch is needed: that dispatch will
        // hit this exact same check and also stop.
        return false;
      }

      if (players[botUid] !== undefined) {
        // This slot was already filled by a previous delivery of this
        // same task. Don't add a second bot for it, but the room may
        // still have room for the *next* slot.
        return currentCount < MAX_PLAYERS_PER_ROOM;
      }

      if (currentCount >= MAX_PLAYERS_PER_ROOM) {
        return false;
      }

      const bot = generateBotProfile(botUid);
      tx.update(roomRef, {
        // Partial `players.$uid` write — same pattern
        // `_joinRoomTransaction` uses for a human join — so this can
        // never clobber a concurrent human join/leave/kick touching a
        // different player's entry.
        [`players.${botUid}`]: {
          displayName: bot.displayName,
          avatarUrl: bot.avatarUrl,
          joinedAt: Timestamp.now(),
        },
        playerUids: FieldValue.arrayUnion(botUid),
      });

      return currentCount + 1 < MAX_PLAYERS_PER_ROOM;
    });

    if (!shouldRescheduleNext) return;

    await enqueueBotFillTask(
      {roomId, sequence: sequence + 1},
      randomBetween(MIN_BOT_FILL_DELAY_SECONDS, MAX_BOT_FILL_DELAY_SECONDS),
    );
  },
);
