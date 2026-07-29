// Core imports:
import '/core/validator/validator.dart';

// Features imports:
import '/features/room/domain/usecases/join_room_usecase.dart';
import '/features/room/domain/validators/room_validation_error.dart';

class JoinRoomValidator
    implements Validator<JoinRoomParams, RoomValidationError> {
  @override
  List<RoomValidationError> validate(JoinRoomParams value) {
    final errors = <RoomValidationError>[];

    if (value.roomId.trim().isEmpty) {
      errors.add(RoomValidationError.emptyRoomId);
    }

    return errors;
  }
}
