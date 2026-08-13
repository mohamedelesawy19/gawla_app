import {onDocumentCreated} from "firebase-functions/v2/firestore";
import {logger} from "firebase-functions/v2";
import {
  ROOMS_COLLECTION,
  ROOM_STATUS_WAITING,
} from "../tournament/tournament_types";
import {
  MAX_BOT_FILL_DELAY_SECONDS,
  MIN_BOT_FILL_DELAY_SECONDS,
} from "./bot_constants";
import {enqueueBotFillTask} from "./bot_fill_queue";
import {randomBetween} from "./bot_time_utils";

/**
 * Rooms are created directly by the Flutter client
 * (`RoomRemoteDataSourceImpl.createRoom` writes straight to Firestore —
 * there is no `createRoom` Cloud Function to hook a callable into), so
 * the bot-fill chain has to start from a Firestore trigger instead of
 * being kicked off inline by server code. This is the ONLY place the
 * chain is seeded; every subsequent link is `fillRoomWithBot`
 * rescheduling itself (see `bot_fill_queue.ts`).
 *
 * Fires on creation only (not every write) — the "am I still eligible"
 * checks live entirely in `fillRoomWithBot`'s own transaction, so this
 * trigger only ever needs to run once per room, right at the start of
 * its life.
 */
export const scheduleBotFillOnRoomCreated = onDocumentCreated(
  {
    region: "europe-west6",
    document: `${ROOMS_COLLECTION}/{roomId}`,
  },
  async (event) => {
    const roomId = event.params.roomId as string;
    const data = event.data?.data();

    if (!data) {
      logger.warn("bots: room-created event with no data", {roomId});
      return;
    }
    if (data.status !== ROOM_STATUS_WAITING) {
      // Rooms are always created `waiting` today, but this stays
      // future-proof if that ever changes (e.g. a pre-filled room type).
      return;
    }

    await enqueueBotFillTask(
      {roomId, sequence: 1},
      randomBetween(MIN_BOT_FILL_DELAY_SECONDS, MAX_BOT_FILL_DELAY_SECONDS),
    );
  },
);
