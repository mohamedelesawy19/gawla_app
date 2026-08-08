import 'package:flutter/material.dart';

// Core imports:
import '/core/localization/localization_helpers.dart';

// Project imports:
import '/features/mini_games/domain/mini_game_play_args.dart';
import '/features/mini_games/presentation/mini_game_definition.dart';

/// `MINI_GAMES_LIBRARY.md §4.6` — commit-then-reveal Rock/Paper/Scissors
/// duel.
///
/// Notably, this game needs NO new infrastructure: the "commit" half of
/// commit-then-reveal is entirely a `submit_round_result.ts` concern (the
/// raw choice is written to a private `_duelCommits` doc the opponent's
/// client can never read — see that file's doc comment), so there's
/// nothing for this widget to do to enforce secrecy beyond simply not
/// rendering the opponent's choice until it's already been resolved and
/// revealed in `RoundResultEntity.metadata`. `MiniGamePlayArgs.opponentUid`
/// and `TournamentRoundEntity.resultFor` already carry everything needed
/// — a good example of the earlier Tournament refactor already having
/// done its job.
class OddOneOutDefinition implements MiniGameDefinition {
  const OddOneOutDefinition();

  @override
  String get gameId => 'odd_one_out';

  @override
  Widget build(BuildContext context, MiniGamePlayArgs args) {
    return _OddOneOutGameWidget(args: args);
  }
}

class _OddOneOutGameWidget extends StatefulWidget {
  const _OddOneOutGameWidget({required this.args});

  final MiniGamePlayArgs args;

  @override
  State<_OddOneOutGameWidget> createState() => _OddOneOutGameWidgetState();
}

class _OddOneOutGameWidgetState extends State<_OddOneOutGameWidget> {
  static const _choices = ['rock', 'paper', 'scissors'];

  String? _myChoice;

  void _pick(String choice) {
    if (_myChoice != null || widget.args.isPerformingAction) return;

    setState(() => _myChoice = choice);
    widget.args.onSubmit({'choice': choice});
  }

  String _localizedChoice(String choice) {
    return switch (choice) {
      'rock' => context.l10n.oddOneOutRock,
      'paper' => context.l10n.oddOneOutPaper,
      'scissors' => context.l10n.oddOneOutScissors,
      _ => choice,
    };
  }

  @override
  Widget build(BuildContext context) {
    final opponentUid = widget.args.opponentUid;
    final myResult = widget.args.round.resultFor(widget.args.viewerUid);

    if (opponentUid == null) {
      // Odd pool -> automatic bye, nothing to play
      // (`duel_loser_strategy.ts`'s `prepareGroups`).
      return Center(child: Text(context.l10n.oddOneOutBye));
    }

    if (_myChoice == null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            context.l10n.oddOneOutChooseMove,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            children: _choices
                .map(
                  (choice) => ElevatedButton(
                    onPressed: () => _pick(choice),
                    child: Text(_localizedChoice(choice)),
                  ),
                )
                .toList(growable: false),
          ),
        ],
      );
    }

    if (myResult?.passed == null) {
      // Pending — this player has committed, but the opponent hasn't
      // yet (or a tie is being re-duelled server-side); `passed` stays
      // `null` until `submitRoundResult` resolves both sides together.
      return Center(child: Text(context.l10n.oddOneOutWaitingForOpponent));
    }

    // Resolved — `metadata` carries the safe-to-reveal choices, set the
    // moment the second duelist commits.
    final revealed = myResult?.metadata;
    final won = myResult?.passed == true;

    final myChoice = _localizedChoice(revealed?['myChoice'] as String? ?? '');
    final opponentChoice = _localizedChoice(
      revealed?['opponentChoice'] as String? ?? '',
    );

    return Center(
      child: Text(
        won
            ? context.l10n.oddOneOutWon(myChoice, opponentChoice)
            : context.l10n.oddOneOutLost(opponentChoice, myChoice),
        style: Theme.of(context).textTheme.titleMedium,
        textAlign: TextAlign.center,
      ),
    );
  }
}
