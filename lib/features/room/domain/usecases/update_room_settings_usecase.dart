// Package imports:
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

// Core imports:
import '/core/errors/failures.dart';
import '/core/services/current_player/current_player_service.dart';
import '/core/usecases/usecase.dart';

// Features imports:
import '/features/room/domain/entities/room_settings_entity.dart';
import '/features/room/domain/repositories/room_repository.dart';
import '/features/room/domain/validators/room_settings_validator.dart';

/// Updates a room's settings.
class UpdateRoomSettingsUseCase
    implements UseCase<void, UpdateRoomSettingsParams> {
  const UpdateRoomSettingsUseCase({
    required this._repository,
    required this._currentPlayer,
    required this._validator,
  });

  final RoomRepository _repository;
  final CurrentPlayerService _currentPlayer;
  final RoomSettingsValidator _validator;

  @override
  Future<Either<Failure, void>> call(UpdateRoomSettingsParams params) async {
    final errors = _validator.validate(params.settings);

    if (errors.isNotEmpty) {
      return Left(ValidationFailure(errors: errors));
    }

    final uidResult = await _currentPlayer.getCurrentUid();

    return uidResult.fold(
      Left.new,
      (hostUid) => _repository.updateRoomSettings(
        roomId: params.roomId,
        hostUid: hostUid,
        settings: params.settings,
      ),
    );
  }
}

class UpdateRoomSettingsParams extends Equatable {
  const UpdateRoomSettingsParams({
    required this.roomId,
    required this.settings,
  });

  final String roomId;
  final RoomSettingsEntity settings;

  @override
  List<Object?> get props => [roomId, settings];
}
