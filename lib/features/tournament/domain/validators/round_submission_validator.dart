// Core imports:
import '/core/validator/validator.dart';

// Package imports:
import '/features/tournament/domain/entities/tournament_enums.dart';
import '/features/tournament/domain/usecases/submit_round_result_usecase.dart';
import '/features/tournament/domain/validators/tournament_validation_error.dart';

/// Pure, client-side pre-flight checks for a round-result submission.
///
/// These exist purely to fail fast on a stale or mistimed UI (e.g. a tap
/// that lands after the round already advanced) without a network round
/// trip. They are *not* the source of truth for whether a submission is
/// legal — that's the server's job, per the project's anti-cheat rules —
/// so this validator only rules out cases that are already unambiguous
/// from state the caller has in memory.
abstract final class RoundSubmissionValidator
    implements Validator<SubmitRoundResultParams, TournamentValidationError> {
  const RoundSubmissionValidator();

  @override
  List<TournamentValidationError> validate(SubmitRoundResultParams params) {
    final errors = <TournamentValidationError>[];

    if (params.tournament.status != TournamentStatus.inProgress) {
      errors.add(TournamentValidationError.notInProgress);
    }

    if (params.roundIndex != params.tournament.currentRoundIndex) {
      errors.add(TournamentValidationError.roundAlreadyEnded);
    }

    final round = params.tournament.currentRound;
    if (round == null || round.status != RoundStatus.active) {
      errors.add(TournamentValidationError.roundNotActive);
    }

    if (params.payload.isEmpty) {
      errors.add(TournamentValidationError.emptyResultPayload);
    }

    return errors;
  }
}
