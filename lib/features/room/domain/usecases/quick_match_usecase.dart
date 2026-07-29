// Package imports:
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

// Core imports:
import '/core/errors/failures.dart';
import '/core/usecases/usecase.dart';

// Features imports:
import '/features/room/domain/entities/room_entity.dart';
import '/features/room/domain/entities/room_enums.dart';
import '/features/room/domain/entities/room_settings_entity.dart';
import '/features/room/domain/repositories/room_repository.dart';

/// Public-room matchmaking: joins the first open public room, or creates
/// one if none is available.
///
/// This try-then-fallback orchestration across two repository calls is
/// genuine business logic, so it lives here rather than being pushed
/// down into the repository or data source.
class QuickMatchUseCase implements UseCase<RoomEntity, QuickMatchParams> {
  const QuickMatchUseCase(this._repository);

  final RoomRepository _repository;

  @override
  Future<Either<Failure, RoomEntity>> call(QuickMatchParams params) async {
    final openRoomResult = await _repository.findOpenPublicRoom();

    Failure? failure;
    RoomEntity? openRoom;
    openRoomResult.fold((l) => failure = l, (r) => openRoom = r);

    if (failure != null) return Left(failure!);

    if (openRoom == null) {
      return _repository.createRoom(
        hostUid: params.uid,
        hostDisplayName: params.displayName,
        hostAvatarUrl: params.avatarUrl,
        visibility: RoomVisibility.public,
        settings: params.defaultSettings,
      );
    }

    return _repository.joinRoom(
      roomId: openRoom!.roomId,
      uid: params.uid,
      displayName: params.displayName,
      avatarUrl: params.avatarUrl,
    );
  }
}

class QuickMatchParams extends Equatable {
  const QuickMatchParams({
    required this.uid,
    required this.displayName,
    this.avatarUrl,
    this.defaultSettings = const RoomSettingsEntity(
      maxPlayers: 24,
      tournamentSize: 5,
      miniGameRotation: [],
    ),
  });

  final String uid;
  final String displayName;
  final String? avatarUrl;

  /// Used only if no open public room is found and a new one has to be
  /// created on the player's behalf.
  final RoomSettingsEntity defaultSettings;

  @override
  List<Object?> get props => [uid, displayName, avatarUrl, defaultSettings];
}
