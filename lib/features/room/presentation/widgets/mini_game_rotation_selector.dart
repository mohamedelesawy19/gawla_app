// Package imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Core imports:
import '/core/design_system/borders.dart';
import '/core/design_system/spacing.dart';
import '/core/widgets/interactions/pressable_scale.dart';

// Feature imports:
import '/features/room/presentation/constants/mini_game_catalog.dart';

/// Lets the host build an ordered [RoomSettingsEntity.miniGameRotation]
/// by tapping chips in the order they should be played. A selected chip
/// shows its round number in place of its icon; tapping it again removes
/// it (and every chip after it is renumbered automatically, since order
/// is derived from [selectedIds] itself rather than tracked separately).
class MiniGameRotationSelector extends StatelessWidget {
  const MiniGameRotationSelector({
    super.key,
    required this.selectedIds,
    required this.onChanged,
  });

  final List<String> selectedIds;
  final ValueChanged<List<String>> onChanged;

  void _toggle(String id) {
    HapticFeedback.selectionClick();
    final next = List<String>.from(selectedIds);
    if (!next.remove(id)) {
      next.add(id);
    }
    onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final entry in MiniGameCatalog.mvpSet)
          _MiniGameChip(
            entry: entry,
            order: selectedIds.contains(entry.id)
                ? selectedIds.indexOf(entry.id) + 1
                : null,
            onTap: () => _toggle(entry.id),
          ),
      ],
    );
  }
}

class _MiniGameChip extends StatelessWidget {
  const _MiniGameChip({
    required this.entry,
    required this.order,
    required this.onTap,
  });

  final MiniGameCatalogEntry entry;
  final int? order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selected = order != null;

    return PressableScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: AppBorders.borderRadiusFull,
          border: Border.all(
            color: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected)
              Container(
                width: 20,
                height: 20,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onPrimary,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$order',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              )
            else
              Icon(
                entry.icon,
                size: 18,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            AppSpacing.horizontalSpaceSm,
            Text(
              entry.label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: selected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
