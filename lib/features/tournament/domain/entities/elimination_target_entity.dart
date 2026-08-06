// Package imports:
import 'package:equatable/equatable.dart';

// Feature imports:
import '/features/tournament/domain/entities/tournament_enums.dart';

/// How many players a round's elimination cuts, either as an absolute
/// headcount or a fraction of the active pool. Mirrors
/// `EliminationTargetDoc` on the Cloud Functions side 1:1.
///
/// Only meaningful for elimination types that need a tunable cut size —
/// [EliminationType.rankCutoff] always uses it; [EliminationType.teamLoss]
/// uses it optionally (present = "eliminate this many of the losing team's
/// weakest contributors" instead of the whole team). Every other
/// elimination type is intrinsic (a duel always cuts the loser, a
/// composite final always cuts to one winner) and never carries a target —
/// see `MiniGameConfigEntity.eliminationTarget`'s nullability.
class EliminationTargetEntity extends Equatable {
  const EliminationTargetEntity({required this.kind, required this.value});

  final EliminationTargetKind kind;

  /// [EliminationTargetKind.count]: an absolute headcount.
  /// [EliminationTargetKind.percentage]: a 0..1 fraction of the pool.
  final num value;

  @override
  List<Object?> get props => [kind, value];
}
