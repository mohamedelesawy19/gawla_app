// Package imports:
import 'package:flutter/material.dart';

// Core imports:
import '/core/design_system/spacing.dart';
import '/core/localization/localization_helpers.dart';
import '/core/widgets/common/count_badge.dart';
import '/core/widgets/common/section_header.dart';

// Feature imports:
import '/features/room/domain/entities/room_enums.dart';
import '/features/room/presentation/widgets/mini_game_rotation_selector.dart';
import '/features/room/presentation/widgets/room_visibility_selector.dart';
import '/features/room/presentation/widgets/selected_rotation_preview.dart';

/// Pure form for every field that makes up a room + its
/// [RoomSettingsEntity] — shared between [CreateRoomScreen] and the
/// host's "Edit settings" sheet on [RoomScreen].
///
/// Owns no state of its own. Every field's current value and its change
/// callback are supplied by the caller (a Smart screen), per the Dumb
/// Widget contract — this keeps the same form reusable in both places
/// without duplicating layout or validation.
class RoomSettingsForm extends StatelessWidget {
  const RoomSettingsForm({
    super.key,
    required this.visibility,
    required this.onVisibilityChanged,
    required this.miniGameRotation,
    required this.onMiniGameRotationChanged,
    this.showVisibilitySelector = true,
  });

  final RoomVisibility visibility;
  final ValueChanged<RoomVisibility> onVisibilityChanged;

  final List<String> miniGameRotation;
  final ValueChanged<List<String>> onMiniGameRotationChanged;

  /// The host can only pick Public/Private while creating a room — a
  /// live room's visibility isn't editable mid-lobby, so the host's
  /// "Edit settings" sheet passes `false` to hide this section.
  final bool showVisibilitySelector;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showVisibilitySelector) ...[
          SectionHeader(
            icon: Icons.visibility_rounded,
            title: context.l10n.roomVisibility,
            subtitle: context.l10n.roomVisibilitySubtitle,
          ),
          const SizedBox(height: AppSpacing.md),
          RoomVisibilitySelector(
            value: visibility,
            onChanged: onVisibilityChanged,
          ),
          const SizedBox(height: AppSpacing.xxxl),
        ],
        SectionHeader(
          icon: Icons.videogame_asset_rounded,
          title: context.l10n.miniGameRotation,
          subtitle: context.l10n.miniGameRotationSubtitle,
          trailing: miniGameRotation.isEmpty
              ? null
              : InfoBadge(
                  label: context.l10n.gamesSelected(miniGameRotation.length),
                ),
        ),
        const SizedBox(height: AppSpacing.md),
        if (miniGameRotation.isNotEmpty) ...[
          SelectedRotationPreview(orderedIds: miniGameRotation),
          const SizedBox(height: AppSpacing.md),
        ],
        MiniGameRotationSelector(
          selectedIds: miniGameRotation,
          onChanged: onMiniGameRotationChanged,
        ),
      ],
    );
  }
}
