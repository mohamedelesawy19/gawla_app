// Package imports:
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

// Core imports:
import '/core/errors/failures.dart';
import '/core/usecases/usecase.dart';

// Feature imports:
import '/features/tournament/domain/entities/tournament_entity.dart';
import '/features/tournament/domain/repositories/tournament_repository.dart';
import '/features/tournament/domain/validators/round_submission_validator.dart';

/// Submits a player's raw result for the tournament's current round.
///
/// Runs [RoundSubmissionValidator] before touching the network so an
/// obviously stale submission (wrong round, tournament already over, ...)
/// fails immediately with a [ValidationFailure] instead of a wasted round
/// trip. A submission that passes this check can still be rejected by the
/// server — this only rules out cases that are already unambiguous
/// client-side.
class SubmitRoundResultUseCase
    implements UseCase<Unit, SubmitRoundResultParams> {
  const SubmitRoundResultUseCase({
    required this._repository,
    required this._validator,
  });

  final TournamentRepository _repository;
  final RoundSubmissionValidator _validator;

  @override
  Future<Either<Failure, Unit>> call(SubmitRoundResultParams params) async {
    final errors = _validator.validate(params);
    if (errors.isNotEmpty) return Left(ValidationFailure(errors: errors));

    return _repository.submitRoundResult(
      tournamentId: params.tournament.tournamentId,
      roundIndex: params.roundIndex,
      payload: params.payload,
    );
  }
}

class SubmitRoundResultParams extends Equatable {
  const SubmitRoundResultParams({
    required this.tournament,
    required this.roundIndex,
    required this.payload,
  });

  /// The caller's last-known tournament state. Used only for
  /// `RoundSubmissionValidator`'s pure, client-side checks — never sent
  /// to the server. The server re-derives everything it needs from
  /// `tournament.tournamentId` and the authenticated uid, so a stale
  /// [tournament] here can only cause an unnecessary local rejection,
  /// never an invalid write.
  final TournamentEntity tournament;

  final int roundIndex;

  /// Raw, mini-game-specific result data (e.g. `{'reactionTimeMs': 254}`
  /// or `{'correctAnswers': 7, 'totalTimeMs': 9400}`). Opaque to the
  /// Tournament feature by design — see `RoundResultEntity`'s doc comment.
  final Map<String, dynamic> payload;

  @override
  List<Object?> get props => [tournament, roundIndex, payload];
}
