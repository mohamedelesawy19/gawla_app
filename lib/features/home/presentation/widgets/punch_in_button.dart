// Package imports:
import 'package:flutter/material.dart';

// Core imports:
import '/core/localization/localization_helpers.dart';
import '/core/theme/theme_extensions.dart';
import '/core/widgets/design_system/colors.dart';

class PunchInButton extends StatefulWidget {
  const PunchInButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  State<PunchInButton> createState() => _PunchInButtonState();
}

class _PunchInButtonState extends State<PunchInButton>
    with TickerProviderStateMixin {
  late final AnimationController _breathe = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  )..repeat(reverse: true);

  late final AnimationController _press = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 120),
    reverseDuration: const Duration(milliseconds: 220),
  );

  @override
  void dispose() {
    _breathe.dispose();
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final colorScheme = context.colorScheme;

    return GestureDetector(
      onTapDown: (_) => _press.forward(),
      onTapUp: (_) {
        _press.reverse();
        widget.onTap();
      },
      onTapCancel: () => _press.reverse(),
      child: AnimatedBuilder(
        animation: Listenable.merge([_breathe, _press]),
        builder: (context, child) {
          final breatheScale = 1.0 + (_breathe.value * 0.035);
          final pressScale = 1.0 - (_press.value * 0.08);
          final glow = 0.35 + (_breathe.value * 0.25);
          return Transform.scale(
            scale: breatheScale * pressScale,
            child: Container(
              width: 156,
              height: 156,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.secondary.withValues(alpha: glow),
                    blurRadius: 42,
                    spreadRadius: 6,
                  ),
                ],
              ),
              child: child,
            ),
          );
        },
        child: Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.goldGradient,
          ),
          child: Center(
            child: Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: colorScheme.surface.withValues(alpha: 0.18),
                  width: 2,
                ),
              ),
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.bolt_rounded,
                    color: colorScheme.surface,
                    size: 30,
                  ),
                  Text(
                    context.l10n.punchIn,
                    style: textTheme.titleLarge!.copyWith(
                      color: colorScheme.surface,
                      fontSize: 17,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
