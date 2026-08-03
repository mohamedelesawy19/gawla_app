// Core imports:
import '/core/usecases/usecase.dart';

// Feature imports:
import '/features/tournament/domain/entities/tournament_entity.dart';
import '/features/tournament/domain/repositories/tournament_repository.dart';

/// Realtime stream of a single tournament's state, keyed by
/// `SingleParam.value` = tournamentId.
class WatchTournamentUseCase
    implements StreamUseCase<TournamentEntity?, SingleParam<String>> {
  const WatchTournamentUseCase(this._repository);

  final TournamentRepository _repository;

  @override
  Stream<TournamentEntity?> call(SingleParam<String> params) {
    return _repository.watchTournament(params.value);
  }
}
