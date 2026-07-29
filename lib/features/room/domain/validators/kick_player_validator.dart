// Core imports:
import '/core/validator/validator.dart';

// Features imports:
import '/features/room/domain/usecases/kick_player_usecase.dart';
import '/features/room/domain/validators/room_validation_error.dart';

class KickPlayerValidator
    implements Validator<KickPlayerParams, RoomValidationError> {
  @override
  List<RoomValidationError> validate(KickPlayerParams value) {
    final errors = <RoomValidationError>[];

    if (value.hostUid == value.targetUid) {
      errors.add(RoomValidationError.hostCannotKickSelf);
    }

    return errors;
  }
}
