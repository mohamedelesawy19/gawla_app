// Package imports:
import 'package:dartz/dartz.dart';

// Core imports:
import '/core/errors/exceptions.dart';
import '/core/errors/failures.dart';

// Feature imports:
import '/features/room/data/datasources/room_remote_data_source.dart';
import '/features/room/data/models/room_model.dart';
import '/features/room/data/models/room_settings_model.dart';
import '/features/room/domain/entities/room_entity.dart';
import '/features/room/domain/entities/room_enums.dart';
import '/features/room/domain/entities/room_settings_entity.dart';
import '/features/room/domain/repositories/room_repository.dart';

class RoomRepositoryImpl implements RoomRepository {
  const RoomRepositoryImpl({required this._remoteDataSource});

  final RoomRemoteDataSource _remoteDataSource;

  // ── Streams ──────────────────────────────────────────────────────────────

  @override
  Stream<RoomEntity?> watchRoom(String roomId) {
    return _remoteDataSource
        .watchRoom(roomId)
        .map((model) => model?.toEntity());
  }

  @override
  Stream<String?> watchRoomIdForUser(String uid) {
    return _remoteDataSource.watchRoomIdForUser(uid);
  }

  // ── Create / discover ────────────────────────────────────────────────────

  @override
  Future<Either<Failure, RoomEntity>> createRoom({
    required String hostUid,
    required String hostDisplayName,
    String? hostAvatarUrl,
    required RoomVisibility visibility,
    required RoomSettingsEntity settings,
  }) async {
    try {
      final model = await _remoteDataSource.createRoom(
        hostUid: hostUid,
        hostDisplayName: hostDisplayName,
        hostAvatarUrl: hostAvatarUrl,
        visibility: visibility,
        settings: RoomSettingsModel.fromEntity(settings),
      );
      return Right(model.toEntity());
    } on BaseException catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, RoomEntity?>> findOpenPublicRoom() async {
    try {
      final model = await _remoteDataSource.findOpenPublicRoom();
      return Right(model?.toEntity());
    } on BaseException catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  // ── Join ─────────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, RoomEntity>> joinRoom({
    required String roomId,
    required String uid,
    required String displayName,
    String? avatarUrl,
  }) async {
    try {
      final model = await _remoteDataSource.joinRoom(
        roomId: roomId,
        uid: uid,
        displayName: displayName,
        avatarUrl: avatarUrl,
      );
      return Right(model.toEntity());
    } on BaseException catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, RoomEntity>> joinRoomByInviteCode({
    required String inviteCode,
    required String uid,
    required String displayName,
    String? avatarUrl,
  }) async {
    try {
      final model = await _remoteDataSource.joinRoomByInviteCode(
        inviteCode: inviteCode,
        uid: uid,
        displayName: displayName,
        avatarUrl: avatarUrl,
      );
      return Right(model.toEntity());
    } on BaseException catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  // ── Leave / kick ─────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, void>> leaveRoom({
    required String roomId,
    required String uid,
  }) async {
    try {
      await _remoteDataSource.leaveRoom(
        roomId: roomId,
        computeNextState: (model) => _withPlayerRemoved(model, uid),
      );
      return const Right(null);
    } on BaseException catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> kickPlayer({
    required String roomId,
    required String hostUid,
    required String targetUid,
  }) async {
    try {
      await _remoteDataSource.kickPlayer(
        roomId: roomId,
        hostUid: hostUid,
        targetUid: targetUid,
        computeNextState: (model) => _withPlayerRemoved(model, targetUid),
      );
      return const Right(null);
    } on BaseException catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  /// Round-trips [model] through [RoomEntity.withPlayerRemoved] so the
  /// removal/host-reassignment rule stays defined in exactly one place
  /// (the domain entity) while still being usable from the data
  /// source's Model-typed transaction callback.
  RoomModel? _withPlayerRemoved(RoomModel model, String uid) {
    final nextEntity = model.toEntity().withPlayerRemoved(uid);
    return nextEntity == null ? null : RoomModel.fromEntity(nextEntity);
  }

  // ── Settings ─────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, void>> updateRoomSettings({
    required String roomId,
    required String hostUid,
    required RoomSettingsEntity settings,
  }) async {
    try {
      await _remoteDataSource.updateRoomSettings(
        roomId: roomId,
        hostUid: hostUid,
        settings: RoomSettingsModel.fromEntity(settings),
      );
      return const Right(null);
    } on BaseException catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  // ── Error mapping ────────────────────────────────────────────────────────

  Failure _mapExceptionToFailure(BaseException exception) {
    return switch (exception) {
      AuthException() => AuthFailure(
        message: exception.message,
        code: exception.code,
      ),
      NetworkException() => NetworkFailure(
        message: exception.message,
        code: exception.code,
      ),
      ParsingException() => ParsingFailure(
        message: exception.message,
        code: exception.code,
      ),
      ServerException() => ServerFailure(
        message: exception.message,
        code: exception.code,
      ),
      _ => UnknownFailure(message: exception.message, code: exception.code),
    };
  }
}
