// Package imports:
import 'package:flutter/material.dart';

// Core imports:
import '/core/theme/app_colors.dart';

enum SnackType { info, success, warning, error }

class CustomSnackbar {
  CustomSnackbar._();

  static void show(
    BuildContext context, {
    required String message,
    SnackType type = SnackType.info,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final style = _styleFor(type);

    final snackBar = SnackBar(
      duration: duration,
      behavior: SnackBarBehavior.floating,
      backgroundColor: style.color,
      elevation: 6,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: style.border, width: 3),
      ),
      content: Row(
        children: [
          Icon(style.icon, color: style.border, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: style.onColor,
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

  static _SnackStyle _styleFor(SnackType type) {
    switch (type) {
      case SnackType.success:
        return const _SnackStyle(
          color: AppColors.successContainer,
          border: AppColors.success,
          onColor: AppColors.onSuccessContainer,
          icon: Icons.emoji_events_rounded,
        );
      case SnackType.warning:
        return const _SnackStyle(
          color: AppColors.warningContainer,
          border: AppColors.warning,
          onColor: AppColors.onWarningContainer,
          icon: Icons.bolt_rounded,
        );
      case SnackType.error:
        return const _SnackStyle(
          color: AppColors.errorContainer,
          border: AppColors.error,
          onColor: AppColors.onErrorContainer,
          icon: Icons.heart_broken_rounded,
        );
      case SnackType.info:
        return const _SnackStyle(
          color: AppColors.tertiaryContainer,
          border: AppColors.tertiary,
          onColor: AppColors.onTertiaryContainer,
          icon: Icons.shield_rounded,
        );
    }
  }
}

class _SnackStyle {
  const _SnackStyle({
    required this.color,
    required this.onColor,
    required this.border,
    required this.icon,
  });

  final Color color;
  final Color onColor;
  final Color border;
  final IconData icon;
}
