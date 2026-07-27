// Package imports:
import 'package:equatable/equatable.dart';

// Feature imports:
import '/features/home/domain/entities/mini_game_preview_entity.dart';

class HomeDashboardEntity extends Equatable {
  const HomeDashboardEntity({
    required this.tournamentPlayerCount,
    required this.tournamentRoundCount,
    required this.todaysRotation,
    required this.gameLibrary,
  });

  final int tournamentPlayerCount;
  final int tournamentRoundCount;
  final List<MiniGamePreviewEntity> todaysRotation;
  final List<MiniGamePreviewEntity> gameLibrary;

  @override
  List<Object?> get props => [
    tournamentPlayerCount,
    tournamentRoundCount,
    todaysRotation,
    gameLibrary,
  ];
}
