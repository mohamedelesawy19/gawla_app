// Package imports:
import 'package:flutter/material.dart';

// Core imports:
import '/core/design_system/colors.dart';

class GlowingIcon extends StatelessWidget {
  const GlowingIcon({
    super.key,
    required this.icon,
    this.width,
    this.height,
    this.gradientColors,
  });

  final IconData icon;
  final double? width;
  final double? height;
  final List<Color>? gradientColors;

  @override
  Widget build(BuildContext context) {
    final colors =
        gradientColors ?? [AppColors.brandPrimary, AppColors.brandPrimaryDark];

    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer Glow
        Container(
          width: width != null ? width! * 1.3 : 90,
          height: height != null ? height! * 1.3 : 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors.first.withValues(alpha: 0.1),
          ),
        ),
        // Inner Circle with Gradient
        Container(
          width: width ?? 70,
          height: height ?? 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors,
            ),
            boxShadow: [
              BoxShadow(
                color: colors.first.withValues(alpha: 0.4),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(icon, size: 32, color: AppColors.textPrimary),
        ),
      ],
    );
  }
}
