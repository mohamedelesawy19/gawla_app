import '/core/validator/validator.dart';

enum TournamentValidationError implements ValidationError {
  // This tournament is not currently active.
  notInProgress,

  // This round has already ended.
  roundAlreadyEnded,

  // This round is not currently accepting results.
  roundNotActive,

  // No result data to submit.
  emptyResultPayload,
}
