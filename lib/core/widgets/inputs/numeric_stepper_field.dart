// Package imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Core imports:
import '/core/design_system/borders.dart';

/// A reusable stepper for editing bounded integer values.
///
/// Displays a label, decrement/increment controls, and an optional
/// progress indicator showing the current value within the configured
/// range.
///
/// This widget is stateless. The parent owns the current value and
/// handles updates through [onChanged].
class NumericStepperField extends StatelessWidget {
  const NumericStepperField({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.step = 1,
  });

  final String label;
  final int value;
  final int min;
  final int max;
  final int step;
  final ValueChanged<int> onChanged;

  bool get _canDecrement => value - step >= min;
  bool get _canIncrement => value + step <= max;
  double get _progress => max == min ? 1 : (value - min) / (max - min);

  void _change(int next) {
    HapticFeedback.selectionClick();
    onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _StepperButton(
                  icon: Icons.remove_rounded,
                  onPressed: _canDecrement ? () => _change(value - step) : null,
                ),
                SizedBox(
                  width: 48,
                  child: Text(
                    '$value',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                _StepperButton(
                  icon: Icons.add_rounded,
                  onPressed: _canIncrement ? () => _change(value + step) : null,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: AppBorders.borderRadiusFull,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: _progress.clamp(0.0, 1.0)),
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOut,
            builder: (context, animatedProgress, _) => LinearProgressIndicator(
              value: animatedProgress,
              minHeight: 5,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
            ),
          ),
        ),
      ],
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final enabled = onPressed != null;
    return IconButton.filledTonal(
      onPressed: onPressed,
      icon: Icon(icon),
      style: IconButton.styleFrom(
        backgroundColor: enabled
            ? theme.colorScheme.secondaryContainer
            : theme.colorScheme.surfaceContainerHighest,
        foregroundColor: enabled
            ? theme.colorScheme.onSecondaryContainer
            : theme.colorScheme.onSurface.withValues(alpha: 0.38),
      ),
    );
  }
}
