// Package imports:
import 'package:meta/meta.dart';

// Feature imports:
import '/features/tournament/domain/entities/tournament_round_entity.dart';

/// Everything a mini-game's gameplay widget needs to play a single round
/// and report its outcome — the one seam between the Tournament feature
/// (owns lifecycle/state) and the Mini Games feature (owns interaction).
///
/// Deliberately narrow: a mini-game widget never reads `TournamentEntity`
/// or depends on `TournamentBloc` directly, and never decides elimination
/// itself — it only renders [round]'s mechanic and, once the player
/// finishes, calls [onSubmit] with a raw, mini-game-specific payload.
/// Everything downstream (scoring, ranking, elimination) is already owned
/// by `submitRoundResult` + the `EliminationStrategy` registry on the
/// Cloud Functions side; duplicating any of that here would be exactly
/// the "parallel engine" this feature has to avoid.
@immutable
class MiniGamePlayArgs {
  const MiniGamePlayArgs({
    required this.tournamentId,
    required this.round,
    required this.viewerUid,
    required this.isPerformingAction,
    required this.onSubmit,
  });

  final String tournamentId;

  /// The active round this widget is rendering. Always
  /// `status == RoundStatus.active` — `MiniGameHost` never mounts a game
  /// widget for a pending/completed round (`TournamentContent`'s
  /// `_RoundStage` already routes completed rounds to
  /// `TournamentRoundResultsView` instead).
  final TournamentRoundEntity round;

  final String viewerUid;

  /// True while a previous submission from this player is still in
  /// flight (mirrors `TournamentState.isPerformingAction`). A game widget
  /// should disable further input while this is true rather than allow a
  /// second submit attempt — `TournamentSubmitRoundResultEvent` is
  /// `droppable()` anyway, but disabling input avoids a confusing "did my
  /// tap register?" moment for the player.
  final bool isPerformingAction;

  /// Raw, game-specific result data — shape must match whatever
  /// `MiniGameDefinition.isPlausible`/`normalize` for this `gameId`
  /// expects on the Cloud Functions side (see `functions/src/mini_games/
  /// *.ts`). Calling this dispatches `TournamentSubmitRoundResultEvent`
  /// for [round] under the hood; the widget itself never touches
  /// `TournamentBloc`.
  final void Function(Map<String, dynamic> payload) onSubmit;

  /// This player's opponent in a duel round, or `null` if [round] isn't
  /// grouped, or this player drew a bye (`duel_loser_strategy.ts`'s
  /// odd-pool handling). Convenience over `round.groupAssignments`, used
  /// by duel-style widgets (Odd One Out) to know who they're facing.
  String? get opponentUid {
    final myGroup = round.groupIdFor(viewerUid);
    if (myGroup == null) return null;
    final assignments = round.groupAssignments;
    if (assignments == null) return null;
    for (final entry in assignments.entries) {
      if (entry.key != viewerUid && entry.value == myGroup) return entry.key;
    }
    return null;
  }

  /// Every uid sharing this player's group — teammates in a `teamLoss`
  /// round, or both duelists in a `duelLoser` round. Empty if [round]
  /// isn't grouped for this player.
  List<String> get groupmateUids {
    final myGroup = round.groupIdFor(viewerUid);
    final assignments = round.groupAssignments;
    if (myGroup == null || assignments == null) return const [];
    return assignments.entries
        .where((e) => e.value == myGroup)
        .map((e) => e.key)
        .toList(growable: false);
  }
}
