import 'package:flutter/material.dart';
import 'package:gawla_app/core/design_system/borders.dart';

class InfoBadge extends StatelessWidget {
  const InfoBadge({
    super.key,
    required this.label,
    this.icon,
    this.background,
    this.foreground,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  });

  final String label;
  final IconData? icon;
  final Color? background;
  final Color? foreground;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: background ?? theme.colorScheme.secondaryContainer,
        borderRadius: AppBorders.borderRadiusFull,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 14,
              color: foreground ?? theme.colorScheme.onSecondaryContainer,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: foreground ?? theme.colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
