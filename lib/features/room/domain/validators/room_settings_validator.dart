// Package imports:
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

    if (settings.miniGameRotation.isEmpty) {
      errors.add(RoomValidationError.emptyMiniGameRotation);
    }

    return errors;
  }
}
