// Dart imports:
import 'dart:async';

// Package imports:
import 'package:flutter/material.dart';

// Core imports:
import '/core/localization/localization_helpers.dart';

// Project imports:
import '/features/mini_games/domain/mini_game_play_args.dart';
import '/features/mini_games/domain/realtime_game_channel.dart';
import '/features/mini_games/presentation/mini_game_definition.dart';

/// `MINI_GAMES_LIBRARY.md §4.7` — rapid tapping aggregated into a live
/// team total. The live rope/meter is a `RealtimeGameChannel` concern
/// (every player's taps aggregated near-real-time); the eventual
/// `submitRoundResult` payload is just this player's own final tap
/// count, matching `team_games.ts`'s `tugOfPowerDefinition` exactly —
/// this widget never sums team totals itself or decides who lost, that
/// stays `teamLossStrategy`'s job.
///
/// Expected channel schema at
/// `miniGameChannels/{roundIndex}/tug_of_power`: `{teamPower: {teamA:
/// number, teamB: number}}`, aggregated server-side from `pushEvent`
/// input by a `driveTugOfPowerRound` function (also responsible for the
/// per-user tap-rate cap the library doc calls for — this widget's own
/// tap handler intentionally applies no client-side cap of its own,
/// since a client-side cap is trivially bypassable and would only ever
/// be a UX nicety, never the actual anti-cheat boundary).
class TugOfPowerDefinition implements MiniGameDefinition {
  const TugOfPowerDefinition({required this.channel});
  final RealtimeGameChannel channel;

  @override
  String get gameId => 'tug_of_power';

  @override
  Widget build(BuildContext context, MiniGamePlayArgs args) {
    return _TugOfPowerGameWidget(args: args, channel: channel);
  }
}

class _TugOfPowerGameWidget extends StatefulWidget {
  const _TugOfPowerGameWidget({required this.args, required this.channel});
  final MiniGamePlayArgs args;
  final RealtimeGameChannel channel;

  @override
  State<_TugOfPowerGameWidget> createState() => _TugOfPowerGameWidgetState();
}

class _TugOfPowerGameWidgetState extends State<_TugOfPowerGameWidget> {
  late final String _channelPath =
      'miniGameChannels/'
      '${widget.args.tournamentId}/'
      '${widget.args.round.roundIndex}/'
      'tug_of_power';

  late final DateTime _startedAt =
      widget.args.round.startedAt ?? DateTime.now();

  int _myTaps = 0;
  Timer? _endTimer;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    final endsAt = widget.args.round.endsAt;
    if (endsAt != null) {
      final remaining = endsAt.difference(DateTime.now());
      _endTimer = Timer(
        remaining.isNegative ? Duration.zero : remaining,
        _submitFinal,
      );
    }
  }

  void _tap() {
    if (widget.args.isPerformingAction || _submitted) return;
    setState(() => _myTaps++);
    widget.channel.pushEvent(_channelPath, {
      'uid': widget.args.viewerUid,
      'taps': _myTaps,
    });
  }

  void _submitFinal() {
    if (_submitted) return;
    _submitted = true;
    final endsAt = widget.args.round.endsAt ?? DateTime.now();
    widget.args.onSubmit({
      'tapCount': _myTaps,
      'roundDurationMs': endsAt.difference(_startedAt).inMilliseconds,
    });
  }

  String _formatTeam(String? team) {
    return switch (team) {
      'teamA' => 'A',
      'teamB' => 'B',
      null || '' => '-',
      _ => team,
    };
  }

  @override
  void dispose() {
    _endTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final myTeam = widget.args.round.groupIdFor(widget.args.viewerUid);

    return StreamBuilder<Map<String, dynamic>>(
      stream: widget.channel.watch(_channelPath),
      builder: (context, snapshot) {
        final teamPower = (snapshot.data?['teamPower'] as Map?) ?? const {};
        final teamA = (teamPower['teamA'] as num?)?.toDouble() ?? 0;
        final teamB = (teamPower['teamB'] as num?)?.toDouble() ?? 0;
        final total = (teamA + teamB).clamp(1, double.infinity);

        return Column(
          children: [
            Text(
              context.l10n.tugOfPowerTeam(_formatTeam(myTeam)),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: (teamA / total * 100).round().clamp(1, 99),
                  child: Container(height: 16, color: Colors.blue),
                ),
                Expanded(
                  flex: (teamB / total * 100).round().clamp(1, 99),
                  child: Container(height: 16, color: Colors.red),
                ),
              ],
            ),
            const Spacer(),
            GestureDetector(
              onTap: _tap,
              child: Container(
                height: 120,
                alignment: Alignment.center,
                color: Colors.orangeAccent,
                child: Text(context.l10n.tugOfPowerPull),
              ),
            ),
          ],
        );
      },
    );
  }
}
