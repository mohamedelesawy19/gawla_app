// Package imports:
import 'package:flutter/material.dart';

// Core imports:
import '/core/design_system/borders.dart';
import '/core/design_system/colors.dart';
import '/core/design_system/spacing.dart';

enum SnackType { info, success, warning, error }

class CustomSnackbar {
  const CustomSnackbar._();

  static void show(
    BuildContext context, {
    required String message,
    SnackType type = SnackType.info,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final style = _styleFor(type, context);

    final snackBar = SnackBar(
      duration: duration,
      behavior: SnackBarBehavior.floating,
      backgroundColor: style.background,
      elevation: 6,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: AppBorders.borderRadiusXl,
        side: BorderSide(color: style.border, width: 3),
      ),
      content: Row(
        children: [
          Icon(style.icon, color: style.foreground, size: 22),
          AppSpacing.horizontalSpaceSm,
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: style.foreground,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
      action: (actionLabel != null && onAction != null)
          ? SnackBarAction(
              label: actionLabel.toUpperCase(),
              textColor: style.border,
              onPressed: onAction,
            )
          : null,
    );

    ScaffoldMessenger.maybeOf(context)
      ?..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  static void info(BuildContext context, String message) =>
      show(context, message: message);

  static void success(BuildContext context, String message) =>
      show(context, message: message, type: SnackType.success);

  static void warning(BuildContext context, String message) =>
      show(context, message: message, type: SnackType.warning);

  static void error(BuildContext context, String message) => show(
    context,
    message: message,
    type: SnackType.error,
    duration: const Duration(seconds: 4),
  );

  static _SnackStyle _styleFor(SnackType type, BuildContext context) {
    switch (type) {
      case SnackType.success:
        return const _SnackStyle(
          background: AppColors.statusSuccess,
          foreground: AppColors.surfaceElevated,
          border: AppColors.statusSuccess,
          icon: Icons.emoji_events_rounded,
        );

      case SnackType.warning:
        return const _SnackStyle(
          background: AppColors.statusWarning,
          foreground: AppColors.surfaceElevated,
          border: AppColors.statusWarning,
          icon: Icons.bolt_rounded,
        );

      case SnackType.error:
        return const _SnackStyle(
          background: AppColors.statusError,
          foreground: AppColors.surfaceElevated,
          border: AppColors.statusError,
          icon: Icons.heart_broken_rounded,
        );

      case SnackType.info:
        return const _SnackStyle(
          background: AppColors.statusInfo,
          foreground: AppColors.surfaceElevated,
          border: AppColors.statusInfo,
          icon: Icons.shield_rounded,
        );
    }
  }
}

class _SnackStyle {
  const _SnackStyle({
    required this.background,
    required this.foreground,
    required this.border,
    required this.icon,
  });

  final Color background;
  final Color foreground;
  final Color border;
  final IconData icon;
}
