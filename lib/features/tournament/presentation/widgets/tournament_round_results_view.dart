// Package imports:
import 'package:flutter/material.dart';

// Core imports:
import '/core/design_system/spacing.dart';
import '/core/design_system/typography.dart';
import '/core/localization/localization_helpers.dart';

// Feature imports:
import '/features/tournament/domain/entities/tournament_entity.dart';
import '/features/tournament/domain/entities/tournament_player_entity.dart';
import '/features/tournament/domain/entities/tournament_round_entity.dart';
import '/features/tournament/presentation/widgets/round_result_row.dart';
import '/features/tournament/presentation/widgets/tournament_elimination_overlay.dart';

/// Results screen shown for the beat between a round closing
/// ([RoundStatus.completed]) and the next round going live — every
/// player's rank/score for [round], plus a dedicated elimination beat if
/// the round just cut the local player.
class TournamentRoundResultsView extends StatelessWidget {
  const TournamentRoundResultsView({
    super.key,
    required this.tournament,
    required this.round,
    required this.viewerUid,
  });

  final TournamentEntity tournament;
  final TournamentRoundEntity round;
  final String? viewerUid;

  TournamentPlayerEntity? _playerFor(String uid) {
    for (final player in tournament.players) {
      if (player.uid == uid) return player;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final results = [...round.results]
      ..sort((a, b) => (a.rank ?? 999).compareTo(b.rank ?? 999));

    final viewerResult = viewerUid == null ? null : round.resultFor(viewerUid!);
    final viewerJustEliminated = viewerResult?.eliminated ?? false;
    final viewerRank = viewerResult?.rank;

    return Stack(
      children: [
        Column(
          children: [
            AppSpacing.verticalSpaceXl,
            Text(
              context.l10n.tournamentRoundResultsTitle(round.roundIndex + 1),
              style: AppTypography.headlineSmall,
            ),
            AppSpacing.verticalSpaceLg,
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                itemCount: results.length,
                separatorBuilder: (_, _) => AppSpacing.verticalSpaceSm,
                itemBuilder: (context, index) {
                  final result = results[index];
                  return RoundResultRow(
                    result: result,
                    player: _playerFor(result.uid),
                    isViewer: result.uid == viewerUid,
                  );
                },
              ),
            ),
            AppSpacing.verticalSpaceLg,
          ],
        ),
        if (viewerJustEliminated && viewerRank != null)
          TournamentEliminationOverlay(rank: viewerRank),
      ],
    );
  }
}
