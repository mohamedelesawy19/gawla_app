// Core imports:
import '/core/usecases/usecase.dart';

// Feature imports:
import '/features/tournament/domain/repositories/tournament_repository.dart';

/// Realtime stream of the active tournamentId for a room, keyed by
/// `SingleParam.value` = roomId.
///
/// This is the piece `SessionBloc`'s doc comment refers to as
/// "implemented later by the Tournament feature". Wire it in at the
/// composition root.
class WatchTournamentIdForRoomUseCase
    implements StreamUseCase<String?, SingleParam<String>> {
  const WatchTournamentIdForRoomUseCase(this._repository);

  final TournamentRepository _repository;

  @override
  Stream<String?> call(SingleParam<String> params) {
    return _repository.watchTournamentIdForRoom(params.value);
  }
}
