// Package imports:
import 'package:dartz/dartz.dart';

// Core imports:
import '/core/errors/failures.dart';

// Feature imports:
import '/features/room/domain/entities/room_entity.dart';
import '/features/room/domain/entities/room_enums.dart';
import '/features/room/domain/entities/room_settings_entity.dart';

/// Contract for all Room-feature persistence. The domain and
/// presentation layers depend only on this interface — never on
/// Firestore directly — so the backend can change without touching
/// business logic.
abstract class RoomRepository {
  /// Realtime stream of a single room. Emits `null` if the room does
  /// not exist (or was deleted/closed).
  Stream<RoomEntity?> watchRoom(String roomId);

  /// Realtime stream of the id of the room [uid] currently belongs to,
  /// or `null` if they're not in one.
  Stream<String?> watchRoomIdForUser(String uid);

  Future<Either<Failure, RoomEntity>> createRoom({
    required String hostUid,
    required String hostDisplayName,
    String? hostAvatarUrl,
    required RoomVisibility visibility,
    required RoomSettingsEntity settings,
  });

  /// Finds a joinable public room.
  /// Returns `Right(null)` (not a failure) when none is available.
  Future<Either<Failure, RoomEntity?>> findOpenPublicRoom();

  /// Joins a specific room by id (e.g. picked from a public room
  /// browser, or a deep link).
  Future<Either<Failure, RoomEntity>> joinRoom({
    required String roomId,
    required String uid,
    required String displayName,
    String? avatarUrl,
  });

  /// Joins a private room using its invite code.
  Future<Either<Failure, RoomEntity>> joinRoomByInviteCode({
    required String inviteCode,
    required String uid,
    required String displayName,
    String? avatarUrl,
  });

  Future<Either<Failure, void>> leaveRoom({
    required String roomId,
    required String uid,
  });

  /// Removes [targetUid] from the room. Only [hostUid] may do this.
  Future<Either<Failure, void>> kickPlayer({
    required String roomId,
    required String hostUid,
    required String targetUid,
  });

  /// Updates room settings. Only the host may do this, and only while
  /// the room is still [RoomStatus.waiting].
  Future<Either<Failure, void>> updateRoomSettings({
    required String roomId,
    required String hostUid,
    required RoomSettingsEntity settings,
  });
}
