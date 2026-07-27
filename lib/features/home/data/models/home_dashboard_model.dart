// Package imports:
import 'package:equatable/equatable.dart';

// Feature imports:
import '/features/home/data/models/mini_game_preview_model.dart';
import '/features/home/domain/entities/home_dashboard_entity.dart';

class HomeDashboardModel extends Equatable {
  const HomeDashboardModel({
    required this.tournamentPlayerCount,
    required this.tournamentRoundCount,
    required this.todaysRotation,
    required this.gameLibrary,
  });

  final int tournamentPlayerCount;
  final int tournamentRoundCount;
  final List<MiniGamePreviewModel> todaysRotation;
  final List<MiniGamePreviewModel> gameLibrary;

  // ── Entity mapping ─────────────────────────────────────────────────────────

  factory HomeDashboardModel.fromEntity(HomeDashboardEntity entity) {
    return HomeDashboardModel(
      tournamentPlayerCount: entity.tournamentPlayerCount,
      tournamentRoundCount: entity.tournamentRoundCount,
      todaysRotation: entity.todaysRotation
          .map(MiniGamePreviewModel.fromEntity)
          .toList(),
      gameLibrary: entity.gameLibrary
          .map(MiniGamePreviewModel.fromEntity)
          .toList(),
    );
  }

  HomeDashboardEntity toEntity() {
    return HomeDashboardEntity(
      tournamentPlayerCount: tournamentPlayerCount,
      tournamentRoundCount: tournamentRoundCount,
      todaysRotation: todaysRotation.map((e) => e.toEntity()).toList(),
      gameLibrary: gameLibrary.map((e) => e.toEntity()).toList(),
    );
  }

  @override
  List<Object?> get props => [
    tournamentPlayerCount,
    tournamentRoundCount,
    todaysRotation,
    gameLibrary,
  ];
}
