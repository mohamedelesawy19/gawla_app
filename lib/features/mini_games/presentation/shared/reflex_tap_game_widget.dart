// Dart imports:
import 'dart:async';
import 'dart:math';

// Package imports:
import 'package:flutter/material.dart';

// Project imports:
import '/features/mini_games/domain/mini_game_play_args.dart';

enum _Phase { waiting, triggered, done }

/// Reusable "wait for the signal, tap the instant it appears" mechanic —
/// the shared shape behind Reaction Tap, Color Challenge, and Musical
/// Freeze (`MINI_GAMES_LIBRARY.md §3.1, §3.5, §4.3`). Concrete games
/// differ only in copy, timing window, and — for Musical Freeze — where
/// the trigger comes from; everything else (the wait state, the flash,
/// the false-start guard, the stopwatch) is identical. Reusing this one
/// widget for all three is exactly the kind of duplication a bespoke
/// `MiniGameDefinition` per game would otherwise reproduce.
///
/// Matches `scored_games.ts`'s `reflexDefinition`: submits
/// `{reactionTimeMs}` on a real tap, or `{falseStart: true}` if the
/// player taps before the trigger — which `rankCutoffStrategy` always
/// eliminates regardless of the round's cut percentage.
///
/// NOTE on timing authority: today's `reflexDefinition` (Cloud Functions
/// side) trusts this client-reported `reactionTimeMs` within a plausible
/// bound (120ms–10s) rather than computing it from a server-broadcast
/// trigger timestamp, even though `PROJECT_OVERVIEW.md` calls for
/// server-authoritative timing on reflex games. This widget is built
/// against that current, actually-implemented contract. Closing that gap
/// later means driving the trigger through `RealtimeGameChannel` instead
/// of a local `Timer` (the same pattern `FreezeFrenzyGameWidget` already
/// uses) and reporting `reactionTimeMs` computed from the server's own
/// trigger broadcast — a backend + this-widget change together, not
/// something to fake from the client alone.
class ReflexTapGameWidget extends StatefulWidget {
  const ReflexTapGameWidget({
    super.key,
    required this.args,
    required this.promptLabel,
    required this.triggerLabel,
    this.minDelay = const Duration(milliseconds: 1500),
    this.maxDelay = const Duration(milliseconds: 4500),
  });

  final MiniGamePlayArgs args;
  final String promptLabel;
  final String triggerLabel;
  final Duration minDelay;
  final Duration maxDelay;

  @override
  State<ReflexTapGameWidget> createState() => _ReflexTapGameWidgetState();
}

class _ReflexTapGameWidgetState extends State<ReflexTapGameWidget> {
  _Phase _phase = _Phase.waiting;
  Timer? _triggerTimer;
  Stopwatch? _stopwatch;

  @override
  void initState() {
    super.initState();
    _scheduleTrigger();
  }

  void _scheduleTrigger() {
    final spanMs = (widget.maxDelay - widget.minDelay).inMilliseconds;
    final delay =
        widget.minDelay +
        Duration(milliseconds: Random().nextInt(max(spanMs, 1)));
    _triggerTimer = Timer(delay, () {
      if (!mounted) return;
      setState(() {
        _phase = _Phase.triggered;
        _stopwatch = Stopwatch()..start();
      });
    });
  }

  void _handleTap() {
    if (_phase == _Phase.done || widget.args.isPerformingAction) return;

    if (_phase == _Phase.waiting) {
      // Tapped before the signal — a forced elimination, not just a slow
      // score.
      _triggerTimer?.cancel();
      setState(() => _phase = _Phase.done);
      widget.args.onSubmit({'falseStart': true});
      return;
    }

    _stopwatch?.stop();
    setState(() => _phase = _Phase.done);
    widget.args.onSubmit({
      'reactionTimeMs': _stopwatch?.elapsedMilliseconds ?? 0,
    });
  }

  @override
  void dispose() {
    _triggerTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTriggered = _phase == _Phase.triggered;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        color: isTriggered ? Colors.greenAccent : theme.colorScheme.surface,
        alignment: Alignment.center,
        child: Text(
          switch (_phase) {
            _Phase.done => '…',
            _Phase.triggered => widget.triggerLabel,
            _Phase.waiting => widget.promptLabel,
          },
          style: theme.textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
