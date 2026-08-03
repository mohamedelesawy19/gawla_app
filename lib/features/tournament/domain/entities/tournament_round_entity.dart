// Package imports:
import 'package:equatable/equatable.dart';

// Feature imports:
import '/features/tournament/domain/entities/round_result_entity.dart';
import '/features/tournament/domain/entities/tournament_enums.dart';

/// A single mini-game round within a tournament.
class TournamentRoundEntity extends Equatable {
  const TournamentRoundEntity({
    required this.roundIndex,
    required this.miniGameId,
    required this.status,
    this.startedAt,
    this.endsAt,
    this.results = const [],
  });

  /// Position within `TournamentEntity.miniGameRotation` — also this round's
  /// identity within the tournament (a tournament never re-orders or repeats a
  /// round).
  final int roundIndex;

  /// Plain mini-game id, same convention as `RoomSettingsEntity.
  /// miniGameRotation` — kept a raw string so Tournament has no compile-time
  /// dependency on the future Mini Games feature. Adding a new mini-game
  /// (Boss Round, Team Battle, ...) never requires a change here.
  final String miniGameId;

  final RoundStatus status;

  /// Server-authoritative; `null` until [status] leaves
  /// [RoundStatus.pending].
  final DateTime? startedAt;

  /// Server-authoritative submission deadline for this round; `null`
  /// until the round goes active.
  final DateTime? endsAt;

  /// One entry per player who was still active when the round began.
  final List<RoundResultEntity> results;

  RoundResultEntity? resultFor(String uid) {
    for (final result in results) {
      if (result.uid == uid) return result;
    }
    return null;
  }

  @override
  List<Object?> get props => [
    roundIndex,
    miniGameId,
    status,
    startedAt,
    endsAt,
    results,
  ];
}
