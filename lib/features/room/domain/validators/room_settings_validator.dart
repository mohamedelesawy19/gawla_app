// Package imports:
import '/core/constants/room_constants.dart';
import '/core/validator/validator.dart';

// Core imports:
import '/features/room/domain/entities/room_settings_entity.dart';
import '/features/room/domain/validators/room_validation_error.dart';

class RoomSettingsValidator
    implements Validator<RoomSettingsEntity, RoomValidationError> {
  const RoomSettingsValidator();

  @override
  List<RoomValidationError> validate(RoomSettingsEntity settings) {
    final errors = <RoomValidationError>[];

    if (settings.maxPlayers < RoomConstants.minPlayersToStart ||
        settings.maxPlayers > RoomConstants.maxPlayersPerRoom) {
      errors.add(RoomValidationError.maxPlayersOutOfRange);
    }
    if (settings.tournamentSize < RoomConstants.minPlayersToStart) {
      errors.add(RoomValidationError.tournamentSizeTooSmall);
    }
    if (settings.tournamentSize > settings.maxPlayers) {
      errors.add(RoomValidationError.tournamentSizeExceedsMaxPlayers);
    }
    if (settings.miniGameRotation.isEmpty) {
      errors.add(RoomValidationError.emptyMiniGameRotation);
    }

    return errors;
  }
}
