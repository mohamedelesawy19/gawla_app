// Core imports:
import '/core/validator/validator.dart';

// Package imports:
import '/features/tournament/domain/entities/tournament_enums.dart';
import '/features/tournament/domain/usecases/submit_round_result_usecase.dart';
import '/features/tournament/domain/validators/tournament_validation_error.dart';

class RoundSubmissionValidator
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
