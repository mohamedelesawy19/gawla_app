// Package imports:
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Core imports:
import '/core/errors/failures.dart';
import '/core/usecases/usecase.dart';

// Feature imports:
import '/features/tournament/domain/entities/tournament_entity.dart';
import '/features/tournament/domain/entities/tournament_round_entity.dart';
import '/features/tournament/domain/usecases/submit_round_result_usecase.dart';
import '/features/tournament/domain/usecases/watch_tournament_usecase.dart';

// Part imports:
part 'tournament_event.dart';
part 'tournament_state.dart';

/// Coordinates the Tournament feature's use cases and exposes a single
/// stream of [TournamentState] for the presentation layer.
///
/// Ownership boundary: this bloc renders and drives a tournament *once its
/// id is known* — right after a successful [TournamentStartEvent], or on
/// rehydration once the app shell tells it to via [TournamentWatchEvent].
/// Deciding *whether* the current room already has a tournament running is
/// `WatchTournamentIdForRoomUseCase`'s job (mirrors how `RoomBloc` leaves
/// `WatchRoomIdForUserUseCase` to `SessionBloc`) — that use case is
/// intentionally not wired in here, only registered in DI for whichever
/// bloc owns that decision.
class TournamentBloc extends Bloc<TournamentEvent, TournamentState> {
  TournamentBloc({
    required this._watchTournament,
    required this._submitRoundResult,
  }) : super(const TournamentState()) {
    // Restartable: a new watch request (including a "stop", i.e. `null`
    // tournamentId) must always supersede whatever was previously being
    // streamed, so the old subscription is cancelled cleanly.
    on<TournamentWatchEvent>(_onWatch, transformer: restartable());
    // Droppable: a round result submission is a one-shot action; a
    // duplicate tap while the first submission is still in flight must
    // never fire a second write.
    on<TournamentSubmitRoundResultEvent>(
      _onSubmitRoundResult,
      transformer: droppable(),
    );
  }

  final WatchTournamentUseCase _watchTournament;
  final SubmitRoundResultUseCase _submitRoundResult;

  Future<void> _onWatch(
    TournamentWatchEvent event,
    Emitter<TournamentState> emit,
  ) async {
    final tournamentId = event.tournamentId;
    if (tournamentId == null) {
      emit(const TournamentState());
      return;
    }

    await emit.forEach<TournamentEntity?>(
      _watchTournament(SingleParam(tournamentId)),
      onData: (tournament) => tournament == null
          // Tournament document is gone (e.g. cancelled and cleaned up
          // server-side) — nothing left to watch.
          ? const TournamentState()
          : state.copyWith(
              status: TournamentBlocStatus.inTournament,
              tournament: tournament,
              isPerformingAction: false,
              clearFailure: true,
            ),
      onError: (error, stackTrace) => state.copyWith(
        status: TournamentBlocStatus.failure,
        failure: ServerFailure(message: error.toString()),
      ),
    );
  }

  Future<void> _onSubmitRoundResult(
    TournamentSubmitRoundResultEvent event,
    Emitter<TournamentState> emit,
  ) async {
    final tournament = state.tournament;
    if (tournament == null) return;

    emit(state.copyWith(isPerformingAction: true, clearFailure: true));

    final result = await _submitRoundResult(
      SubmitRoundResultParams(
        tournament: tournament,
        roundIndex: event.roundIndex,
        payload: event.payload,
      ),
    );

    // No need to touch `tournament` here: the ongoing watch subscription
    // will deliver the scored result (and any resulting elimination) on
    // its own.
    emit(
      result.fold(
        (failure) =>
            state.copyWith(isPerformingAction: false, failure: failure),
        (_) => state.copyWith(isPerformingAction: false),
      ),
    );
  }
}
