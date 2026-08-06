// Package imports:
import 'package:equatable/equatable.dart';

// Feature imports:
import '/features/tournament/data/models/elimination_target_model.dart';
import '/features/tournament/domain/entities/mini_game_config_entity.dart';
import '/features/tournament/domain/entities/tournament_enums.dart';

class MiniGameConfigModel extends Equatable {
  const MiniGameConfigModel({
    required this.gameId,
    required this.roundDurationSec,
    required this.eliminationType,
    this.eliminationTarget,
    this.difficultyModifier,
  });

  final String gameId;
  final int roundDurationSec;
  final EliminationType eliminationType;
  final EliminationTargetModel? eliminationTarget;
  final double? difficultyModifier;

  // ── Firestore ──────────────────────────────────────────────────────────────

  factory MiniGameConfigModel.fromMap(Map<String, dynamic> data) {
    return MiniGameConfigModel(
      gameId: data['gameId'] as String,
      roundDurationSec: (data['roundDurationSec'] as num).toInt(),
      eliminationType: EliminationType.values.byName(
        data['eliminationType'] as String,
      ),
      eliminationTarget: data['eliminationTarget'] == null
          ? null
          : EliminationTargetModel.fromMap(
              data['eliminationTarget'] as Map<String, dynamic>,
            ),
      difficultyModifier: (data['difficultyModifier'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'gameId': gameId,
      'roundDurationSec': roundDurationSec,
      'eliminationType': eliminationType.name,
      'eliminationTarget': eliminationTarget?.toFirestore(),
      'difficultyModifier': difficultyModifier,
    };
  }

  // ── JSON ───────────────────────────────────────────────────────────────────

  factory MiniGameConfigModel.fromJson(Map<String, dynamic> json) {
    return MiniGameConfigModel(
      gameId: json['gameId'] as String,
      roundDurationSec: json['roundDurationSec'] as int,
      eliminationType: EliminationType.values.byName(
        json['eliminationType'] as String,
      ),
      eliminationTarget: json['eliminationTarget'] == null
          ? null
          : EliminationTargetModel.fromJson(
              json['eliminationTarget'] as Map<String, dynamic>,
            ),
      difficultyModifier: (json['difficultyModifier'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gameId': gameId,
      'roundDurationSec': roundDurationSec,
      'eliminationType': eliminationType.name,
      'eliminationTarget': eliminationTarget?.toJson(),
      'difficultyModifier': difficultyModifier,
    };
  }

  // ── Entity mapping ─────────────────────────────────────────────────────────

  factory MiniGameConfigModel.fromEntity(MiniGameConfigEntity entity) {
    return MiniGameConfigModel(
      gameId: entity.gameId,
      roundDurationSec: entity.roundDurationSec,
      eliminationType: entity.eliminationType,
      eliminationTarget: entity.eliminationTarget == null
          ? null
          : EliminationTargetModel.fromEntity(entity.eliminationTarget!),
      difficultyModifier: entity.difficultyModifier,
    );
  }

  MiniGameConfigEntity toEntity() {
    return MiniGameConfigEntity(
      gameId: gameId,
      roundDurationSec: roundDurationSec,
      eliminationType: eliminationType,
      eliminationTarget: eliminationTarget?.toEntity(),
      difficultyModifier: difficultyModifier,
    );
  }

  @override
  List<Object?> get props => [
    gameId,
    roundDurationSec,
    eliminationType,
    eliminationTarget,
    difficultyModifier,
  ];
}
