// Package imports:
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

// Core imports:
import '/core/errors/failures.dart';
import '/core/services/current_player/current_player_service.dart';
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
  const QuickMatchUseCase({
    required this._repository,
    required this._currentPlayer,
  });

  final RoomRepository _repository;
  final CurrentPlayerService _currentPlayer;

  @override
  Future<Either<Failure, RoomEntity>> call(QuickMatchParams params) async {
    final playerResult = await _currentPlayer.getCurrentPlayer();

    return playerResult.fold(Left.new, (player) async {
      final openRoomResult = await _repository.findOpenPublicRoom();

      Failure? failure;
      RoomEntity? openRoom;

      openRoomResult.fold((l) => failure = l, (r) => openRoom = r);

      if (failure != null) {
        return Left(failure!);
      }

      if (openRoom == null) {
        return _repository.createRoom(
          hostUid: player.uid,
          hostDisplayName: player.displayName,
          hostAvatarUrl: player.avatarUrl,
          visibility: RoomVisibility.public,
          settings: params.defaultSettings,
        );
      }

      return _repository.joinRoom(
        roomId: openRoom!.roomId,
        uid: player.uid,
        displayName: player.displayName,
        avatarUrl: player.avatarUrl,
      );
    });
  }
}

class QuickMatchParams extends Equatable {
  const QuickMatchParams({
    this.defaultSettings = const RoomSettingsEntity(miniGameRotation: []),
  });

  /// Used only if no open public room is found and a new one has to be
  /// created on the player's behalf.
  final RoomSettingsEntity defaultSettings;

  @override
  List<Object?> get props => [defaultSettings];
}
