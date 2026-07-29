// Package imports:
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

// Core imports:
import '/core/errors/failures.dart';
import '/core/usecases/usecase.dart';

// Features imports:
import '/features/room/domain/entities/room_settings_entity.dart';
import '/features/room/domain/repositories/room_repository.dart';
import '/features/room/domain/validators/room_settings_validator.dart';

/// Updates a room's settings. Reuses [RoomSettingsEntity.validationError]
/// — the exact same rule [CreateRoomUseCase] enforces — so the two never
/// drift apart.
class UpdateRoomSettingsUseCase
    implements UseCase<void, UpdateRoomSettingsParams> {
  const UpdateRoomSettingsUseCase({
    required this._repository,
    required this._validator,
  });

  final RoomRepository _repository;
  final RoomSettingsValidator _validator;

  @override
  Future<Either<Failure, void>> call(UpdateRoomSettingsParams params) {
    final errors = _validator.validate(params.settings);

    if (errors.isNotEmpty) {
      return Future.value(Left(ValidationFailure(errors: errors)));
    }

    return _repository.updateRoomSettings(
      roomId: params.roomId,
      hostUid: params.hostUid,
      settings: params.settings,
    );
  }
}

class UpdateRoomSettingsParams extends Equatable {
  const UpdateRoomSettingsParams({
    required this.roomId,
    required this.hostUid,
    required this.settings,
  });

  final String roomId;
  final String hostUid;
  final RoomSettingsEntity settings;

  @override
  List<Object?> get props => [roomId, hostUid, settings];
}
