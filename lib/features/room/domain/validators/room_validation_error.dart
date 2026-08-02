import '/core/validator/validator.dart';

enum RoomValidationError implements ValidationError {
  // Room settings
  emptyMiniGameRotation,

  // Join room
  emptyInviteCode,
  invalidInviteCodeLength,
  emptyRoomId,

  // Kick
  hostCannotKickSelf,
}
