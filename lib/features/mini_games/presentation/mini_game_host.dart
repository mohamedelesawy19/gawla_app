// Package imports:
import 'package:flutter/material.dart';

// Core imports:
import '/core/di/service_locator.dart';

// Feature imports:
import '/features/mini_games/domain/mini_game_play_args.dart';
import '/features/mini_games/presentation/mini_game_registry.dart';
import '/features/tournament/domain/entities/tournament_round_entity.dart';

/// The concrete `miniGameHost` builder wired into
/// `TournamentActiveRoundView` at the composition root (see the updated
/// `tournament_content.dart`). This is the ONLY point of contact between
/// the Tournament feature and the Mini Games feature: Tournament decides
/// *when* a round is active and hands this widget the round; this widget
/// (and everything it delegates to via `MiniGameRegistry`) decides *how*
/// that round is played. Neither feature needs to know anything about
/// the other beyond this one seam.
class MiniGameHost extends StatelessWidget {
  const MiniGameHost({
    super.key,
    required this.tournamentId,
    required this.round,
    required this.viewerUid,
    required this.isPerformingAction,
    required this.onSubmit,
  });

  final String tournamentId;
  final TournamentRoundEntity round;
  final String viewerUid;
  final bool isPerformingAction;
  final void Function(Map<String, dynamic>) onSubmit;

  @override
  Widget build(BuildContext context) {
    final registry = ServiceLocator.get<MiniGameRegistry>();
    final definition = registry.definitionFor(round.miniGameId);

    final args = MiniGamePlayArgs(
      tournamentId: tournamentId,
      round: round,
      viewerUid: viewerUid,
      isPerformingAction: isPerformingAction,
      onSubmit: onSubmit,
    );

    // Re-mount with fresh local state whenever the round or its game
    // changes, so leftover state from a previous round's widget (e.g. a
    // half-finished trivia question, a stopwatch already running) can
    // never bleed into the next round's attempt.
    return KeyedSubtree(
      key: ValueKey('${round.roundIndex}_${round.miniGameId}'),
      child: definition.build(context, args),
    );
  }
}
