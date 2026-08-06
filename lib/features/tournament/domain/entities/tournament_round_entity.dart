// Package imports:
import 'package:equatable/equatable.dart';

// Feature imports:
import '/features/tournament/domain/entities/mini_game_config_entity.dart';
import '/features/tournament/domain/entities/round_result_entity.dart';
import '/features/tournament/domain/entities/tournament_enums.dart';

/// A single mini-game round within a tournament.
class TournamentRoundEntity extends Equatable {
  const TournamentRoundEntity({
    required this.roundIndex,
    required this.miniGameConfig,
    required this.status,
    this.startedAt,
    this.endsAt,
    this.results = const [],
    this.groupAssignments,
  });

  /// Position within `TournamentEntity.miniGameRotation` — also this round's
  /// identity within the tournament (a tournament never re-orders or repeats a
  /// round).
  final int roundIndex;

  /// Full server-resolved config for this round's mini-game — duration,
  /// elimination type/target, difficulty. Replaces what used to be a bare
  /// `miniGameId` string: round duration and elimination rule are no
  /// longer a single global default, they're resolved per round (see
  /// `MiniGameConfigEntity`'s doc comment). [miniGameId] remains available
  /// as a convenience getter for callers that only care about the id.
  final MiniGameConfigEntity miniGameConfig;

  final RoundStatus status;

  /// Server-authoritative; `null` until [status] leaves
  /// [RoundStatus.pending].
  final DateTime? startedAt;

  /// Server-authoritative submission deadline for this round; `null`
  /// until the round goes active.
  final DateTime? endsAt;

  /// One entry per player who was still active when the round began.
  final List<RoundResultEntity> results;

  /// uid -> groupId, assigned server-side the moment this round activates
  /// (see the Cloud Functions `EliminationStrategy.prepareGroups`). Only
  /// present for elimination types that group players — a duel pairing
  /// (`EliminationType.duelLoser`, group size 2) or a team split
  /// (`EliminationType.teamLoss`). `null` for every other elimination
  /// type. Lets the Mini Games feature render "you vs. X" / "Team Blue"
  /// before anyone has acted, since players need to know who they're
  /// facing to make sense of the round.
  final Map<String, String>? groupAssignments;

  /// Convenience accessor kept for call sites that only need the id, not
  /// the full round-scheduling config (e.g. an icon in a "next up" strip).
  String get miniGameId => miniGameConfig.gameId;

  RoundResultEntity? resultFor(String uid) {
    for (final result in results) {
      if (result.uid == uid) return result;
    }
    return null;
  }

  /// This player's groupId for the round, or `null` if [groupAssignments]
  /// doesn't apply to this elimination type, or this uid drew a bye in a
  /// duel round (see `duel_loser_strategy.ts`'s odd-pool handling).
  String? groupIdFor(String uid) => groupAssignments?[uid];

  @override
  List<Object?> get props => [
    roundIndex,
    miniGameConfig,
    status,
    startedAt,
    endsAt,
    results,
    groupAssignments,
  ];
}
