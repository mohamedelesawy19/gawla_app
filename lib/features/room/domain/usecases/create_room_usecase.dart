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
import '/features/room/domain/validators/room_settings_validator.dart';

/// Creates a new room. Settings are validated against the domain's rules
/// (see [RoomSettingsEntity.validationError]) before ever reaching the
/// backend.
class CreateRoomUseCase implements UseCase<RoomEntity, CreateRoomParams> {
  const CreateRoomUseCase({
    required this._repository,
    required this._currentPlayer,
    required this._validator,
  });

  final RoomRepository _repository;
  final CurrentPlayerService _currentPlayer;
  final RoomSettingsValidator _validator;

  @override
  Future<Either<Failure, RoomEntity>> call(CreateRoomParams params) async {
    final errors = _validator.validate(params.settings);
    if (errors.isNotEmpty) return Left(ValidationFailure(errors: errors));

    final playerResult = await _currentPlayer.getCurrentPlayer();

    return playerResult.fold(
      Left.new,
      (host) => _repository.createRoom(
        hostUid: host.uid,
        hostDisplayName: host.displayName,
        hostAvatarUrl: host.avatarUrl,
        visibility: params.visibility,
        settings: params.settings,
      ),
    );
  }
}

class CreateRoomParams extends Equatable {
  const CreateRoomParams({required this.visibility, required this.settings});

  final RoomVisibility visibility;
  final RoomSettingsEntity settings;

  @override
  List<Object?> get props => [visibility, settings];
}
