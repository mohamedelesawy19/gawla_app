part of 'tournament_bloc.dart';

enum TournamentBlocStatus { initial, loading, inTournament, failure }

class TournamentState extends Equatable {
  const TournamentState({
    this.status = TournamentBlocStatus.initial,
    this.tournament,
    this.failure,
    this.isPerformingAction = false,
  });

  final TournamentBlocStatus status;

  /// The tournament currently being watched. Present once [status] is
  /// [TournamentBlocStatus.inTournament]; `null` otherwise.
  final TournamentEntity? tournament;

  final Failure? failure;

  /// True while a secondary action — starting the tournament or submitting
  /// a round result — is in flight on top of an already-loaded tournament,
  /// so the UI can show an inline spinner without dropping the current
  /// tournament view.
  final bool isPerformingAction;

  bool get isLoading => status == TournamentBlocStatus.loading;

  bool get isInTournament =>
      status == TournamentBlocStatus.inTournament && tournament != null;

  bool get hasFailure => failure != null;

  /// Convenience for the presentation layer: the round the current player
  /// should be submitting a result for right now, or `null` if the
  /// tournament isn't loaded / the current round hasn't started server-side
  /// yet. Mirrors `TournamentEntity.currentRound`.
  TournamentRoundEntity? get currentRound => tournament?.currentRound;

  TournamentState copyWith({
    TournamentBlocStatus? status,
    TournamentEntity? tournament,
    Failure? failure,
    bool? isPerformingAction,
    bool clearFailure = false,
  }) {
    return TournamentState(
      status: status ?? this.status,
      tournament: tournament ?? this.tournament,
      failure: clearFailure ? null : (failure ?? this.failure),
      isPerformingAction: isPerformingAction ?? this.isPerformingAction,
    );
  }

  @override
  List<Object?> get props => [status, tournament, failure, isPerformingAction];
}
