// Package imports:
import 'package:flutter/material.dart';

// Core imports:
import '/core/localization/localization_helpers.dart';

// Project imports:
import '/features/mini_games/domain/mini_game_play_args.dart';
import '/features/mini_games/domain/realtime_game_channel.dart';
import '/features/mini_games/presentation/mini_game_definition.dart';

/// `MINI_GAMES_LIBRARY.md §4.1` — hold `MOVE` to advance, release the
/// instant the server switches to RED.
///
/// Unlike the scored/accuracy games, this game's fairness depends on
/// *when* the RED/GREEN switch actually happened, which only the server
/// truly knows. So this widget doesn't invent its own local RED/GREEN
/// schedule — that would be exactly the "parallel engine" risk this
/// refactor has to avoid — it renders whatever a `driveFreezeFrenzyRound`
/// Cloud Function pushes through `RealtimeGameChannel`, and only ever
/// submits a *summary* once the mechanic ends, matching
/// `binary_fail_games.ts`'s `freezeFrenzyDefinition` contract exactly:
/// `{movedDuringRed: bool, reachedFinish: bool}`.
///
/// Expected channel schema at
/// `miniGameChannels/{tournamentId}/{roundIndex}/freeze_frenzy` (server-owned,
/// this widget only reads it): `{signal: 'red'|'green', ended: bool,
/// caught_uid: bool, reachedFinish_uid: bool}`. See ARCHITECTURE.md's
/// backend follow-ups for the driver function this depends on.
class FreezeFrenzyDefinition implements MiniGameDefinition {
  const FreezeFrenzyDefinition({required this.channel});
  final RealtimeGameChannel channel;

  @override
  String get gameId => 'freeze_frenzy';

  @override
  Widget build(BuildContext context, MiniGamePlayArgs args) {
    return _FreezeFrenzyGameWidget(args: args, channel: channel);
  }
}

class _FreezeFrenzyGameWidget extends StatefulWidget {
  const _FreezeFrenzyGameWidget({required this.args, required this.channel});
  final MiniGamePlayArgs args;
  final RealtimeGameChannel channel;

  @override
  State<_FreezeFrenzyGameWidget> createState() =>
      _FreezeFrenzyGameWidgetState();
}

class _FreezeFrenzyGameWidgetState extends State<_FreezeFrenzyGameWidget> {
  late final String _channelPath =
      'miniGameChannels/'
      '${widget.args.tournamentId}/'
      '${widget.args.round.roundIndex}/'
      'freeze_frenzy';

  late final Stream<Map<String, dynamic>> _state = widget.channel.watch(
    _channelPath,
  );

  bool _holding = false;
  bool _sawSelfMoveDuringRed = false;
  bool _submitted = false;

  void _setHolding(bool holding, bool isRed) {
    setState(() => _holding = holding);
    widget.channel.pushEvent(_channelPath, {
      'uid': widget.args.viewerUid,
      'holding': holding,
    });
    if (holding && isRed) {
      // Local-only flag so the UI can react instantly; the server's own
      // grace-window check against its authoritative switch timestamp is
      // what actually decides the final outcome (see `caught_<uid>`
      // below).
      _sawSelfMoveDuringRed = true;
    }
  }

  void _maybeSubmit(Map<String, dynamic> state) {
    if (_submitted || state['ended'] != true) return;
    _submitted = true;
    final uid = widget.args.viewerUid;
    widget.args.onSubmit({
      'movedDuringRed': state['caught_$uid'] == true || _sawSelfMoveDuringRed,
      'reachedFinish': state['reachedFinish_$uid'] == true,
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>>(
      stream: _state,
      builder: (context, snapshot) {
        final state = snapshot.data ?? const <String, dynamic>{};
        final isRed = state['signal'] == 'red';

        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _maybeSubmit(state),
        );

        return Column(
          children: [
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: isRed ? Colors.red : Colors.green,
                ),
                child: Center(
                  child: Text(
                    isRed
                        ? context.l10n.freezeFrenzyFreeze
                        : context.l10n.freezeFrenzyGo,
                    style: Theme.of(
                      context,
                    ).textTheme.headlineMedium?.copyWith(color: Colors.white),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTapDown: widget.args.isPerformingAction
                  ? null
                  : (_) => _setHolding(true, isRed),
              onTapUp: (_) => _setHolding(false, isRed),
              onTapCancel: () => _setHolding(false, isRed),
              child: Container(
                height: 96,
                alignment: Alignment.center,
                color: _holding ? Colors.blueAccent : Colors.blueGrey,
                child: Text(context.l10n.freezeFrenzyHoldToMove),
              ),
            ),
          ],
        );
      },
    );
  }
}
