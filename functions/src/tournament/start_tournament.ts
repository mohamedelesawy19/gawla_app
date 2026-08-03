import {getFirestore, Timestamp, FieldValue} from "firebase-admin/firestore";
import {HttpsError, onCall} from "firebase-functions/v2/https";
import {
  DEFAULT_ROUND_DURATION_MS,
  MIN_PLAYERS_TO_START,
  PLAYER_STATUS,
  ROOMS_COLLECTION,
  ROOM_STATUS_IN_PROGRESS,
  ROOM_STATUS_WAITING,
  ROUND_STATUS,
  TOURNAMENTS_COLLECTION,
  TOURNAMENT_STATUS,
  TournamentDoc,
  TournamentPlayerDoc,
  TournamentRoundDoc,
  parseRoomSnapshot,
} from "./tournament_types";

const db = getFirestore();

interface StartTournamentRequest {
  roomId: string;
}

interface StartTournamentResponse {
  tournamentId: string;
}

/**
 * Host-only: turns a room's waiting-room state into a running tournament.
 *
 * Everything the client can't be trusted to decide happens here: host
 * verification, the player/rotation snapshot, and the room-status flip —
 * see `TournamentRemoteDataSource`'s doc comment on the Flutter side for
 * why (a Flutter client is inherently inspectable).
 */
export const startTournament = onCall<StartTournamentRequest>(
  async (request): Promise<StartTournamentResponse> => {
    const uid = request.auth?.uid;
    if (!uid) {
      throw new HttpsError("unauthenticated", "You must be signed in to start a tournament.");
    }

    const roomId = request.data?.roomId;
    if (!roomId || typeof roomId !== "string") {
      throw new HttpsError("invalid-argument", "roomId is required.");
    }

    const roomRef = db.collection(ROOMS_COLLECTION).doc(roomId);
    const tournamentRef = db.collection(TOURNAMENTS_COLLECTION).doc();

    await db.runTransaction(async (tx) => {
      const roomSnap = await tx.get(roomRef);
      if (!roomSnap.exists) {
        throw new HttpsError("not-found", "Room not found.");
      }

      const room = parseRoomSnapshot(roomSnap.data()!);

      if (room.hostUid !== uid) {
        throw new HttpsError("permission-denied", "Only the host can start the tournament.");
      }

      // A tournament can only start while the room is still waiting for players.
      // Any other state (already running, cancelled, closed, ...) is rejected.
      if (room.status !== ROOM_STATUS_WAITING) {
        throw new HttpsError(
          "failed-precondition",
          "This room cannot start a tournament.",
        );
      }

      if (room.players.length < MIN_PLAYERS_TO_START) {
        throw new HttpsError(
          "failed-precondition",
          `Need at least ${MIN_PLAYERS_TO_START} players to start.`,
        );
      }

      if (room.miniGameRotation.length === 0) {
        throw new HttpsError("failed-precondition", "Room has no mini-game rotation configured.");
      }

      const now = Timestamp.now();
      const firstRoundEndsAt = Timestamp.fromMillis(now.toMillis() + DEFAULT_ROUND_DURATION_MS);

      const players: Record<string, TournamentPlayerDoc> = {};
      for (const p of room.players) {
        players[p.uid] = {
          displayName: p.displayName,
          avatarUrl: p.avatarUrl ?? null,
          status: PLAYER_STATUS.active,
          eliminatedAtRoundIndex: null,
          finalPlacement: null,
        };
      }

      const rounds: TournamentRoundDoc[] = room.miniGameRotation.map((miniGameId, index) => ({
        roundIndex: index,
        miniGameId,
        status: index === 0 ? ROUND_STATUS.active : ROUND_STATUS.pending,
        startedAt: index === 0 ? now : null,
        endsAt: index === 0 ? firstRoundEndsAt : null,
        results: [],
      }));

      const tournament: TournamentDoc = {
        roomId,
        hostUid: uid,
        status: TOURNAMENT_STATUS.inProgress,
        miniGameRotation: room.miniGameRotation,
        currentRoundIndex: 0,
        rounds,
        players,
        winnerUid: null,
        createdAt: now,
        completedAt: null,
        currentRoundEndsAt: firstRoundEndsAt,
      };

      tx.set(tournamentRef, tournament);
      tx.update(roomRef, {
        status: ROOM_STATUS_IN_PROGRESS,
        updatedAt: FieldValue.serverTimestamp(),
      });
    });

    return {tournamentId: tournamentRef.id};
  },
);
