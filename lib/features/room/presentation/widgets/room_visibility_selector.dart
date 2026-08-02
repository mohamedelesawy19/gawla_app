// Package imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Core imports:
import '/core/design_system/spacing.dart';
import '/core/localization/localization_helpers.dart';
import '/core/widgets/interactions/pressable_scale.dart';

// Feature imports:
import '/features/room/domain/entities/room_enums.dart';

/// Public/Private selector for [RoomVisibility], rendered as two large
/// tappable cards rather than a plain segmented control so the choice
/// (and its consequence) is legible at a glance.
///
/// Dumb widget — the selected value and the change callback both live
/// with the caller.
class RoomVisibilitySelector extends StatelessWidget {
  const RoomVisibilitySelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final RoomVisibility value;
  final ValueChanged<RoomVisibility> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _VisibilityCard(
            icon: Icons.public_rounded,
            title: context.l10n.public,
            description: context.l10n.publicDescription,
            selected: value == RoomVisibility.public,
            onTap: () => onChanged(RoomVisibility.public),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _VisibilityCard(
            icon: Icons.lock_rounded,
            title: context.l10n.private,
            description: context.l10n.privateDescription,
            selected: value == RoomVisibility.private,
            onTap: () => onChanged(RoomVisibility.private),
          ),
        ),
      ],
    );
  }
}

class _VisibilityCard extends StatelessWidget {
  const _VisibilityCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PressableScale(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  icon,
                  color: selected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 180),
                  opacity: selected ? 1 : 0,
                  child: Icon(
                    Icons.check_circle_rounded,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: selected
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: selected
                    ? theme.colorScheme.onPrimaryContainer.withValues(
                        alpha: 0.8,
                      )
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
