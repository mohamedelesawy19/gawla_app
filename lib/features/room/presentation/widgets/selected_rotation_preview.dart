// Package imports:
import 'package:flutter/material.dart';

// Core imports:
import '/core/design_system/colors.dart';

// Feature imports:
import '/features/room/presentation/constants/mini_game_catalog.dart';

/// Horizontal strip previewing the chosen rotation in play order, so the
/// host can see the sequence they've built without re-reading chip
/// numbers scattered across the [MiniGameRotationSelector]'s wrap.
class SelectedRotationPreview extends StatelessWidget {
  const SelectedRotationPreview({super.key, required this.orderedIds});

  final List<String> orderedIds;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final catalogById = {
      for (final entry in MiniGameCatalog.mvpSet) entry.id: entry,
    };
    final entries = orderedIds
        .map((id) => catalogById[id])
        .whereType<MiniGameCatalogEntry>()
        .toList();

    if (entries.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 64,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: entries.length,
        separatorBuilder: (context, index) => const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Icon(Icons.arrow_forward_rounded, size: 16),
        ),
        itemBuilder: (context, index) {
          final entry = entries[index];
          return SizedBox(
            width: 64,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.cardHover,
                  child: Icon(
                    entry.icon,
                    size: 16,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  entry.label,
                  style: theme.textTheme.labelSmall,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
