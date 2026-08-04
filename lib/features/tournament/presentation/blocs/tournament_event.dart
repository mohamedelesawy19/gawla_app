part of 'tournament_bloc.dart';

sealed class TournamentEvent extends Equatable {
  const TournamentEvent();

  @override
  List<Object?> get props => [];
}

/// Starts streaming realtime updates for [tournamentId], or — when
/// [tournamentId] is `null` — stops watching and resets to
/// [TournamentState]'s initial value.
///
/// Dispatched internally after a successful [TournamentStartEvent], and
/// dispatched by the app shell once it learns (via
/// `WatchTournamentIdForRoomUseCase`, wired in at the composition root for
/// whichever bloc owns that decision) that the current room already has a
/// tournament in progress on app start or rehydration.
final class TournamentWatchEvent extends TournamentEvent {
  const TournamentWatchEvent({this.tournamentId});

  final String? tournamentId;

  @override
  List<Object?> get props => [tournamentId];
}

/// Submits the current player's raw result for the tournament's current
/// round. [roundIndex] is supplied by the caller (rather than read off
/// `TournamentState.currentRound` here) so a UI already mid-submit isn't
/// silently redirected if the round advances underneath it — the
/// server-side `RoundSubmissionValidator` is the actual source of truth
/// for whether the submission is still valid.
final class TournamentSubmitRoundResultEvent extends TournamentEvent {
  const TournamentSubmitRoundResultEvent({
    required this.roundIndex,
    required this.payload,
  });

  final int roundIndex;

  /// Raw, mini-game-specific result data — opaque to this bloc, forwarded
  /// as-is to `SubmitRoundResultUseCase`.
  final Map<String, dynamic> payload;

  @override
  List<Object?> get props => [roundIndex, payload];
}
