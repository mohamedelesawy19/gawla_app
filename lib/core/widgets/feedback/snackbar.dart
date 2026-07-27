// Package imports:
import 'package:flutter/material.dart';

// Core imports:
import '/core/theme/theme_extensions.dart';
import '/core/widgets/design_system/borders.dart';
import '/core/widgets/design_system/spacing.dart';

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
      backgroundColor: style.color,
      elevation: 6,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: AppBorders.borderRadiusXl,
        side: BorderSide(color: style.border, width: 3),
      ),
      content: Row(
        children: [
          Icon(style.icon, color: style.border, size: 22),
          AppSpacing.horizontalSpaceSm,
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

  static _SnackStyle _styleFor(SnackType type, BuildContext context) {
    final colorScheme = context.colorScheme;
    switch (type) {
      case SnackType.success:
        return _SnackStyle(
          color: context.successContainer,
          border: context.successColor,
          onColor: context.onSuccessContainer,
          icon: Icons.emoji_events_rounded,
        );
      case SnackType.warning:
        return _SnackStyle(
          color: context.warningContainer,
          border: context.warningColor,
          onColor: context.onWarningContainer,
          icon: Icons.bolt_rounded,
        );
      case SnackType.error:
        return _SnackStyle(
          color: colorScheme.errorContainer,
          border: colorScheme.error,
          onColor: colorScheme.onErrorContainer,
          icon: Icons.heart_broken_rounded,
        );
      case SnackType.info:
        return _SnackStyle(
          color: colorScheme.tertiaryContainer,
          border: colorScheme.tertiary,
          onColor: colorScheme.onTertiaryContainer,
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
