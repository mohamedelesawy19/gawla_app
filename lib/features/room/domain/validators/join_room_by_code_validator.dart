// Core imports:
import '/core/validator/validator.dart';

// Features imports:
import '/features/room/domain/validators/room_validation_error.dart';

class JoinRoomByCodeValidator
    implements Validator<String, RoomValidationError> {
  @override
  List<RoomValidationError> validate(String inviteCode) {
    final errors = <RoomValidationError>[];

    if (inviteCode.trim().isEmpty) {
      errors.add(RoomValidationError.emptyInviteCode);
    }

    return errors;
  }
}
