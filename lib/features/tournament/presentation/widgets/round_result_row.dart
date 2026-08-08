// Package imports:
import 'package:flutter/material.dart';

// Core imports:
import '/core/design_system/colors.dart';
import '/core/design_system/spacing.dart';
import '/core/design_system/typography.dart';

// Feature imports:
import '/features/tournament/domain/entities/round_result_entity.dart';
import '/features/tournament/domain/entities/tournament_player_entity.dart';
import '/features/tournament/presentation/widgets/tournament_ranked_row.dart';

/// A single player's row in the round results list — rank, name, score,
/// and an eliminated/survived indicator.
///
/// Built on [TournamentRankedRow], the shell it shares with the final
/// standings list on [TournamentWinnerView]; this widget only supplies
/// what's specific to a round result — the score and the alive/eliminated
/// icon — while [TournamentRankedRow] owns the shared row chrome
/// (including the local player's own row being picked out via
/// [AppColors.leaderboardRowSelf], the same way leaderboard screens
/// elsewhere in the app highlight "you").
class RoundResultRow extends StatelessWidget {
  const RoundResultRow({
    super.key,
    required this.result,
    required this.player,
    required this.isViewer,
  });

  final RoundResultEntity result;
  final TournamentPlayerEntity? player;
  final bool isViewer;

  @override
  Widget build(BuildContext context) {
    return TournamentRankedRow(
      rank: result.rank,
      uid: result.uid,
      displayName: player?.displayName ?? '—',
      avatarUrl: player?.avatarUrl,
      isViewer: isViewer,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (result.score != null) ...[
            Text(
              result.score!.toStringAsFixed(0),
              style: AppTypography.labelLarge,
            ),
            AppSpacing.horizontalSpaceMd,
          ],
          Icon(
            result.eliminated
                ? Icons.close_rounded
                : Icons.check_circle_rounded,
            size: 18,
            color: result.eliminated
                ? AppColors.playerEliminated
                : AppColors.playerAlive,
          ),
        ],
      ),
    );
  }
}
