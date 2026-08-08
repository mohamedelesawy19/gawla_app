// Package imports:
import 'package:flutter/material.dart';

// Core imports:
import '/core/widgets/feedback/loading_indicator.dart';

// Feature imports:
import '/features/tournament/domain/entities/tournament_entity.dart';
import '/features/tournament/domain/entities/tournament_enums.dart';
import '/features/tournament/domain/entities/tournament_round_entity.dart';
import '/features/tournament/presentation/widgets/tournament_active_round_view.dart';
import '/features/tournament/presentation/widgets/tournament_round_results_view.dart';
import '/features/tournament/presentation/widgets/tournament_winner_view.dart';

/// Switches on [TournamentEntity.status] — and, while `inProgress`, on the
/// current round's own status — to decide which full-screen beat of the
/// tournament flow to render.
///
/// Deliberately dumb: every branch here is a pure function of
/// `TournamentState.tournament`, so this widget never needs its own state
/// and every sub-view stays a small, independently reviewable widget.
///
/// CHANGE vs. the previous version: `_RoundStage` now supplies
/// `TournamentActiveRoundView.miniGameHost` — the seam that view already
/// exposed for exactly this purpose — so an active round actually renders
/// its mini-game instead of the generic placeholder. This is the only
/// change the Mini Games feature required in the Tournament feature; see
/// `MiniGameHost`'s doc comment for why it's a safe, one-directional
/// dependency (Tournament -> Mini Games only, never the reverse).
class TournamentContent extends StatelessWidget {
  const TournamentContent({
    super.key,
    required this.tournament,
    required this.viewerUid,
    required this.isPerformingAction,
    required this.onSubmit,
    required this.onContinue,
  });

  final TournamentEntity tournament;
  final String? viewerUid;
  final bool isPerformingAction;
  final void Function(Map<String, dynamic>) onSubmit;

  /// Called when the player taps through the terminal (Winner/Defeat)
  /// screen — the only point in this feature where the presentation
  /// layer itself decides to leave the tournament.
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    switch (tournament.status) {
      case TournamentStatus.starting:
        return const Center(child: LoadingIndicator());

      case TournamentStatus.inProgress:
        return _RoundStage(
          tournament: tournament,
          viewerUid: viewerUid,
          isPerformingAction: isPerformingAction,
          onSubmit: onSubmit,
        );

      case TournamentStatus.completed:
      case TournamentStatus.cancelled:
        return TournamentWinnerView(
          tournament: tournament,
          viewerUid: viewerUid,
          onContinue: onContinue,
        );
    }
  }
}

/// Picks between the "round in flight" chrome and the "round just ended"
/// results screen, split out from [TournamentContent.build] purely so
/// that switch reads as one status at a time instead of a nested one.
class _RoundStage extends StatelessWidget {
  const _RoundStage({
    required this.tournament,
    required this.viewerUid,
    required this.isPerformingAction,
    required this.onSubmit,
  });

  final TournamentEntity tournament;
  final String? viewerUid;
  final bool isPerformingAction;
  final void Function(Map<String, dynamic>) onSubmit;

  @override
  Widget build(BuildContext context) {
    final TournamentRoundEntity? round = tournament.currentRound;

    // `round == null` (see `TournamentEntity.currentRound`'s doc comment)
    // and `RoundStatus.pending` are both "nothing to show yet" — the
    // active-round view already renders a "get ready" placeholder for
    // both cases.
    if (round == null || round.status != RoundStatus.completed) {
      return TournamentActiveRoundView(
        tournament: tournament,
        round: round,
        viewerUid: viewerUid,
        isPerformingAction: isPerformingAction,
      );
    }

    return TournamentRoundResultsView(
      tournament: tournament,
      round: round,
      viewerUid: viewerUid,
    );
  }
}
