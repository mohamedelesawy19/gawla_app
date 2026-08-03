// Package imports:
import 'package:equatable/equatable.dart';

// Feature imports:
import '/features/tournament/domain/entities/tournament_enums.dart';
import '/features/tournament/domain/entities/tournament_player_entity.dart';
import '/features/tournament/domain/entities/tournament_round_entity.dart';

/// The full elimination tournament run for a room — everything from
/// `RoomStatus.inProgress` through the Winner Screen in the tournament flow.
///
/// Mirrors `RoomEntity`'s role for the Room feature: a single aggregate
/// the feature's BLoC watches and reduces UI state from. Ownership
/// boundary: once a tournament exists, `RoomEntity` becomes read-only history
/// (per its own doc comment) — this entity is the single source of truth
/// for everything from here through the winner being decided. What
/// happens after (leaderboard update, rewards) reads the terminal state
/// of this entity but isn't this entity's job to compute.
///
/// Unlike `RoomEntity`, this has no `copyWith`: nothing in the domain
/// layer ever constructs a modified `TournamentEntity` client-side — every
/// mutation (scoring, elimination, round advancement) is
/// server-authoritative per the project's anti-cheat rules, so every new
/// instance comes from mapping a fresh snapshot at the data layer.
class TournamentEntity extends Equatable {
  const TournamentEntity({
    required this.tournamentId,
    required this.roomId,
    required this.hostUid,
    required this.status,
    required this.miniGameRotation,
    required this.currentRoundIndex,
    required this.rounds,
    required this.players,
    this.winnerUid,
    required this.createdAt,
    this.completedAt,
  });

  final String tournamentId;
  final String roomId;

  /// Snapshot of the room's host at tournament-creation time, not re-read from
  /// `RoomEntity`. The room becomes read-only history once a tournament
  /// exists, so a tournament in progress must never be affected by whatever
  /// the underlying room document does afterwards.
  final String hostUid;

  final TournamentStatus status;

  /// Snapshot of `RoomSettingsEntity.miniGameRotation` at the moment the
  /// tournament was created, so later edits to a room's settings (a lobby-only
  /// concept that no longer applies once players are mid-tournament) can
  /// never mutate a running tournament. Its length is this tournament's total
  /// round count.
  final List<String> miniGameRotation;

  /// Index into [rounds] / [miniGameRotation] of the round currently
  /// pending or active.
  final int currentRoundIndex;

  /// One entry per round reached so far, oldest first — doubles as the
  /// tournament's history/replay log. Not pre-filled for rounds not yet
  /// reached.
  final List<TournamentRoundEntity> rounds;

  final List<TournamentPlayerEntity> players;

  /// Set once [status] is [TournamentStatus.completed].
  final String? winnerUid;

  final DateTime createdAt;

  /// Set once [status] reaches a terminal value ([TournamentStatus.completed]
  /// or [TournamentStatus.cancelled]).
  final DateTime? completedAt;

  int get totalRounds => miniGameRotation.length;

  bool get isTerminal =>
      status == TournamentStatus.completed ||
      status == TournamentStatus.cancelled;

  bool isHost(String uid) => hostUid == uid;

  bool hasPlayer(String uid) => players.any((player) => player.uid == uid);

  bool isPlayerEliminated(String uid) {
    for (final player in players) {
      if (player.uid == uid) return player.isEliminated;
    }
    return false;
  }

  List<TournamentPlayerEntity> get activePlayers =>
      players.where((player) => player.isActive).toList();

  /// The round players are currently competing in (or waiting to start),
  /// or `null` if [currentRoundIndex] doesn't have a matching entry in
  /// [rounds] yet (e.g. the very first round hasn't been created
  /// server-side yet).
  TournamentRoundEntity? get currentRound {
    for (final round in rounds) {
      if (round.roundIndex == currentRoundIndex) return round;
    }
    return null;
  }

  @override
  List<Object?> get props => [
    tournamentId,
    roomId,
    hostUid,
    status,
    miniGameRotation,
    currentRoundIndex,
    rounds,
    players,
    winnerUid,
    createdAt,
    completedAt,
  ];
}
