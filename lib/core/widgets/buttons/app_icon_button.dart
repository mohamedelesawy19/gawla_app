// Package imports:
import 'package:flutter/material.dart';

// Core imports:
import '/core/design_system/colors.dart';
import '/core/design_system/spacing.dart';

class AppIconButton extends StatelessWidget {
  const AppIconButton({
    required this.icon,
    required this.onTap,
    super.key,
    this.iconSize = 16,
    this.padding = AppSpacing.paddingSm,
    this.backgroundColor,
    this.iconColor,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final double iconSize;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor ?? AppColors.cardHover,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: padding,
          child: Icon(
            icon,
            size: iconSize,
            color: iconColor ?? AppColors.iconDefault,
          ),
        ),
      ),
    );
  }
}
