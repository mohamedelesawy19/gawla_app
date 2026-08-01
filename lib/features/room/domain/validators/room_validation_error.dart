import '/core/validator/validator.dart';

enum RoomValidationError implements ValidationError {
  // Room settings
  maxPlayersOutOfRange,
  tournamentSizeTooSmall,
  tournamentSizeExceedsMaxPlayers,
  emptyMiniGameRotation,

  // Join room
  emptyInviteCode,
  invalidInviteCodeLength,
  emptyRoomId,

  // Kick
  hostCannotKickSelf,
}
