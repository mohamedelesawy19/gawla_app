// Dart imports:
import 'dart:async';

// Package imports:
import 'package:flutter/material.dart';

// Core imports:
import '/core/design_system/colors.dart';
import '/core/design_system/typography.dart';

/// A countdown ring + numeral ticking down to [endsAt], recoloring itself
/// continuously across [AppColors.timerSafe] → [AppColors.timerWarning] →
/// [AppColors.timerCritical] as time runs out — a drift rather than a
/// snap, matching the meaning those three colors are documented to carry
/// while feeling less mechanical at each threshold crossing. A soft glow
/// and a slow breathing pulse take over once the round is genuinely
/// almost over.
///
/// Purely a presentation clock: it never decides when a round ends — the
/// server does, via the round document's own `status` transition — this
/// just gives the player a felt sense of urgency while that happens.
class TournamentRoundTimer extends StatefulWidget {
  const TournamentRoundTimer({
    super.key,
    required this.startedAt,
    required this.endsAt,
  });

  final DateTime startedAt;
  final DateTime endsAt;

  @override
  State<TournamentRoundTimer> createState() => _TournamentRoundTimerState();
}

class _TournamentRoundTimerState extends State<TournamentRoundTimer>
    with SingleTickerProviderStateMixin {
  Timer? _ticker;
  late Duration _remaining;
  late final AnimationController _pulseController;
  bool _wasCritical = false;

  @override
  void initState() {
    super.initState();
    _remaining = widget.endsAt.difference(DateTime.now());
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _syncPulse();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _remaining = widget.endsAt.difference(DateTime.now()));
      _syncPulse();
    });
  }

  @override
  void didUpdateWidget(covariant TournamentRoundTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.endsAt != widget.endsAt) {
      setState(() => _remaining = widget.endsAt.difference(DateTime.now()));
      _syncPulse();
    }
  }

  void _syncPulse() {
    final isCritical = _fraction <= 0.2 && _fraction > 0;
    if (isCritical && !_wasCritical) {
      _pulseController.repeat(reverse: true);
    } else if (!isCritical && _wasCritical) {
      _pulseController
        ..stop()
        ..value = 0;
    }
    _wasCritical = isCritical;
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  double get _fraction {
    final total = widget.endsAt.difference(widget.startedAt).inMilliseconds;
    if (total <= 0) return 0;
    return (_remaining.inMilliseconds / total).clamp(0.0, 1.0);
  }

  /// Continuous safe → warning → critical blend instead of a hard cut, so
  /// the ring drifts in color rather than jumping the instant a threshold
  /// is crossed.
  Color get _color {
    if (_fraction > 0.5) {
      final t = ((_fraction - 0.5) / 0.5).clamp(0.0, 1.0);
      return Color.lerp(AppColors.timerWarning, AppColors.timerSafe, t)!;
    }
    if (_fraction > 0.2) {
      final t = ((_fraction - 0.2) / 0.3).clamp(0.0, 1.0);
      return Color.lerp(AppColors.timerCritical, AppColors.timerWarning, t)!;
    }
    return AppColors.timerCritical;
  }

  String get _label {
    final seconds = _remaining.inSeconds.clamp(0, 5999);
    if (seconds >= 60) {
      final minutes = seconds ~/ 60;
      final remSeconds = seconds % 60;
      return '$minutes:${remSeconds.toString().padLeft(2, '0')}';
    }
    return '$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<Color?>(
      // `begin`/`end` are both the live color: on the very first frame
      // that's a no-op, but on every later rebuild only `end` changes,
      // so this smoothly drifts from whatever color is currently on
      // screen to the new one instead of snapping.
      tween: ColorTween(begin: _color, end: _color),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOut,
      builder: (context, animatedColor, _) {
        final color = animatedColor ?? _color;
        return AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            final scale = 1.0 + (_pulseController.value * 0.08);
            return Transform.scale(scale: scale, child: child);
          },
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.06),
                  blurRadius: 4,
                  spreadRadius: 0.1,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: _fraction, end: _fraction),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOut,
                  builder: (context, value, _) => CircularProgressIndicator(
                    value: value,
                    strokeWidth: 4,
                    strokeCap: StrokeCap.round,
                    backgroundColor: AppColors.progressTrackBackground,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
                Text(
                  _label,
                  style: AppTypography.titleMedium.copyWith(
                    color: color,
                    fontWeight: .w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
