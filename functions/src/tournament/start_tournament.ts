import {FieldValue, Timestamp} from "firebase-admin/firestore";
import {HttpsError, onCall} from "firebase-functions/v2/https";
import {isBotUid} from "../bots/bot_identity";
import {
  getEliminationStrategy,
} from "./elimination/elimination_strategy_registry";
import {getMiniGameConfig} from "./mini_game_catalog";
import {db} from "../shared/firestore";
import {
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
 *
 * Mini-game configs are resolved from the catalog (Remote Config-backed —
 * see `mini_game_catalog.ts`) BEFORE the transaction, since Remote Config
 * reads aren't transactional and there's nothing tournament-specific to
 * race against here (the catalog is the same for every tournament, and its
 * few-minute cache means back-to-back starts don't refetch anyway).
 */
export const startTournament = onCall<StartTournamentRequest>(
  async (request): Promise<StartTournamentResponse> => {
    const uid = request.auth?.uid;
    if (!uid) {
      throw new HttpsError(
        "unauthenticated",
        "You must be signed in to start a tournament.",
      );
    }

    const roomId = request.data?.roomId;
    if (!roomId || typeof roomId !== "string") {
      throw new HttpsError("invalid-argument", "roomId is required.");
    }

    const roomRef = db.collection(ROOMS_COLLECTION).doc(roomId);
    const tournamentRef = db.collection(TOURNAMENTS_COLLECTION).doc();

    // Read outside the transaction: room membership/rotation are read
    // again (and re-validated) from the transactional snapshot below, so
    // this pre-read is only used to know WHICH game ids to resolve configs
    // for — a stale read here just means we resolve configs for a
    // rotation that turns out to be wrong, which the transaction's own
    // re-read will catch anyway.
    const preReadSnap = await roomRef.get();
    const preReadData = preReadSnap.data();
    const rotationIds = preReadData ?
      parseRoomSnapshot(preReadData).miniGameRotation :
      [];
    const resolvedConfigs = await Promise.all(
      rotationIds.map((gameId, index) => getMiniGameConfig(gameId, index)),
    );

    await db.runTransaction(async (tx) => {
      const roomSnap = await tx.get(roomRef);
      if (!roomSnap.exists) {
        throw new HttpsError("not-found", "Room not found.");
      }

      const roomData = roomSnap.data();
      if (!roomData) {
        throw new HttpsError("not-found", "Room not found.");
      }

      const room = parseRoomSnapshot(roomData);

      if (room.hostUid !== uid) {
        throw new HttpsError(
          "permission-denied",
          "Only the host can start the tournament.",
        );
      }

      // A tournament can only start while the room is still waiting for players
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
        throw new HttpsError(
          "failed-precondition",
          "Room has no mini-game rotation configured.",
        );
      }
      if (room.miniGameRotation.join() !== rotationIds.join()) {
        // Rotation changed between the pre-read and the transaction (e.g.
        // the host edited settings mid-request) — fail closed rather than
        // starting with a mismatched set of resolved configs.
        throw new HttpsError(
          "aborted",
          "Room settings changed, please try again.",
        );
      }

      const now = Timestamp.now();

      const players: Record<string, TournamentPlayerDoc> = {};
      for (const p of room.players) {
        players[p.uid] = {
          displayName: p.displayName,
          avatarUrl: p.avatarUrl ?? null,
          status: PLAYER_STATUS.active,
          eliminatedAtRoundIndex: null,
          finalPlacement: null,
          isBot: isBotUid(p.uid),
        };
      }
      const activeUids = room.players.map((p) => p.uid);

      const firstConfig = resolvedConfigs[0];
      const firstRoundEndsAt = Timestamp.fromMillis(
        now.toMillis() + firstConfig.roundDurationSec * 1000,
      );
      const firstStrategy = getEliminationStrategy(firstConfig.eliminationType);

      const rounds: TournamentRoundDoc[] = resolvedConfigs.map(
        (miniGameConfig, index) => ({
          roundIndex: index,
          miniGameConfig,
          status: index === 0 ? ROUND_STATUS.active : ROUND_STATUS.pending,
          startedAt: index === 0 ? now : null,
          endsAt: index === 0 ? firstRoundEndsAt : null,
          results: [],
          groupAssignments: index === 0 ?
            firstStrategy.prepareGroups(activeUids, firstConfig) :
            null,
        }),
      );

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
