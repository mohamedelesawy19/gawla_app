import {getDatabase} from "firebase-admin/database";

/**
 * Shared Realtime Database client, used by the mini-game round drivers
 * (`tug_of_power`, `freeze_frenzy`) that own a live RTDB channel. See
 * `shared/firestore.ts` for the rationale — same pattern, same reasoning.
 */
export const rtdb = getDatabase();
