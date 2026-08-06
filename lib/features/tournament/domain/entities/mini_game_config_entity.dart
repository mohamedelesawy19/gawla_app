// Package imports:
import 'package:equatable/equatable.dart';

// Feature imports:
import '/features/tournament/domain/entities/elimination_target_entity.dart';
import '/features/tournament/domain/entities/tournament_enums.dart';

/// Server-resolved, round-scoping configuration for one mini-game instance
/// — mirrors `MiniGameConfig` on the Cloud Functions side, which resolves
/// it from Remote Config once per round (see `mini_game_catalog.ts`) so
/// balance (duration, cut size) can be tuned without an app release.
///
/// This is what replaced the old single global round duration and a single
/// global elimination fraction: every round carries its own copy of this,
/// resolved at the moment the round is created — see
/// `TournamentRoundEntity.miniGameConfig`.
class MiniGameConfigEntity extends Equatable {
  const MiniGameConfigEntity({
    required this.gameId,
    required this.roundDurationSec,
    required this.eliminationType,
    this.eliminationTarget,
    this.difficultyModifier,
  });

  /// Matches `MINI_GAMES_LIBRARY.md`'s ID column (e.g. `reaction_tap`).
  /// The Mini Games feature's `MiniGameRegistry` looks up a play handler by
  /// this id — Tournament stays ignorant of what the id actually means
  /// beyond scheduling facts (duration, elimination type/target).
  final String gameId;

  final int roundDurationSec;

  final EliminationType eliminationType;

  /// `null` for elimination types that don't need a tunable cut size (see
  /// [EliminationTargetEntity]'s doc comment for exactly which do).
  final EliminationTargetEntity? eliminationTarget;

  /// Optional per-round difficulty scaling (e.g. a shrinking tolerance
  /// margin, a growing sequence length). Opaque to the Tournament feature;
  /// only the Mini Games feature's play handler for [gameId] interprets
  /// its meaning.
  final double? difficultyModifier;

  @override
  List<Object?> get props => [
    gameId,
    roundDurationSec,
    eliminationType,
    eliminationTarget,
    difficultyModifier,
  ];
}
