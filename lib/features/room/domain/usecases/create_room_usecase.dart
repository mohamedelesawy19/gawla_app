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
import '/features/room/domain/validators/room_settings_validator.dart';

/// Creates a new room. Settings are validated against the domain's rules
/// (see [RoomSettingsEntity.validationError]) before ever reaching the
/// backend.
class CreateRoomUseCase implements UseCase<RoomEntity, CreateRoomParams> {
  const CreateRoomUseCase({
    required this._repository,
    required this._validator,
  });

  final RoomRepository _repository;
  final RoomSettingsValidator _validator;

  @override
  Future<Either<Failure, RoomEntity>> call(CreateRoomParams params) {
    final errors = _validator.validate(params.settings);

    if (errors.isNotEmpty) {
      return Future.value(Left(ValidationFailure(errors: errors)));
    }

    return _repository.createRoom(
      hostUid: params.hostUid,
      hostDisplayName: params.hostDisplayName,
      hostAvatarUrl: params.hostAvatarUrl,
      visibility: params.visibility,
      settings: params.settings,
    );
  }
}

class CreateRoomParams extends Equatable {
  const CreateRoomParams({
    required this.hostUid,
    required this.hostDisplayName,
    this.hostAvatarUrl,
    required this.visibility,
    required this.settings,
  });

  final String hostUid;
  final String hostDisplayName;
  final String? hostAvatarUrl;
  final RoomVisibility visibility;
  final RoomSettingsEntity settings;

  @override
  List<Object?> get props => [
    hostUid,
    hostDisplayName,
    hostAvatarUrl,
    visibility,
    settings,
  ];
}
