// Core imports:
import '/core/validator/validator.dart';

// Features imports:
import '/features/room/domain/validators/room_validation_error.dart';

class KickPlayerValidator
    implements Validator<KickPlayerValidationInput, RoomValidationError> {
  @override
  List<RoomValidationError> validate(KickPlayerValidationInput value) {
    final errors = <RoomValidationError>[];

    if (value.hostUid == value.targetUid) {
      errors.add(RoomValidationError.hostCannotKickSelf);
    }

    return errors;
  }
}

class KickPlayerValidationInput {
  const KickPlayerValidationInput({
    required this.hostUid,
    required this.targetUid,
  });

  final String hostUid;
  final String targetUid;
}
