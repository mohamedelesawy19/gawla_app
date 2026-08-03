// Package imports:
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

// Core imports:
import '/core/errors/failures.dart';
import '/core/usecases/usecase.dart';

// Feature imports:
import '/features/tournament/domain/repositories/tournament_repository.dart';

/// Host-only: turns a room's waiting-room state into a running tournament.
///
/// Stays a single server round-trip rather than a client-assembled
/// `TournamentEntity` — the server, not this use case, decides the round
/// count, the player snapshot, and the initial round. See
/// `TournamentRepository.startTournament` for why.
class StartTournamentUseCase implements UseCase<String, StartTournamentParams> {
  const StartTournamentUseCase(this._repository);

  final TournamentRepository _repository;

  @override
  Future<Either<Failure, String>> call(StartTournamentParams params) {
    return _repository.startTournament(params.roomId);
  }
}

class StartTournamentParams extends Equatable {
  const StartTournamentParams({required this.roomId});

  final String roomId;

  @override
  List<Object?> get props => [roomId];
}
