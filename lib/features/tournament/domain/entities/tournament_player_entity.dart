// Package imports:
import 'package:equatable/equatable.dart';

// Feature imports:
import '/features/tournament/domain/entities/tournament_enums.dart';

/// A player's standing inside a single [TournamentEntity].
///
/// Deliberately a *snapshot slice*, same rationale as `RoomPlayerEntity`:
/// [displayName]/[avatarUrl] are copied at tournament-creation time so the
/// tournament stays renderable even if the player's profile changes
/// mid-tournament, and so this feature never has to depend on the Profile
/// feature.
class TournamentPlayerEntity extends Equatable {
  const TournamentPlayerEntity({
    required this.uid,
    required this.displayName,
    this.avatarUrl,
    required this.status,
    this.eliminatedAtRoundIndex,
    this.finalPlacement,
  });

  final String uid;
  final String displayName;
  final String? avatarUrl;
  final TournamentPlayerStatus status;

  /// Index into `TournamentEntity.rounds` of the round that eliminated this
  /// player. `null` while [status] is [TournamentPlayerStatus.active] or
  /// [TournamentPlayerStatus.winner].
  final int? eliminatedAtRoundIndex;

  /// 1-based final ranking (1 = winner). Only meaningful once the tournament
  /// reaches a terminal `TournamentStatus`; consumed later by the Leaderboard
  /// and Rewards features. `null` while the tournament is still running.
  final int? finalPlacement;

  bool get isActive => status == TournamentPlayerStatus.active;
  bool get isEliminated => status == TournamentPlayerStatus.eliminated;
  bool get isWinner => status == TournamentPlayerStatus.winner;

  @override
  List<Object?> get props => [
    uid,
    displayName,
    avatarUrl,
    status,
    eliminatedAtRoundIndex,
    finalPlacement,
  ];
}
