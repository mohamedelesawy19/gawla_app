// Package imports:
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Core imports:
import '/core/design_system/colors.dart';
import '/core/design_system/spacing.dart';
import '/core/design_system/typography.dart';
import '/core/localization/localization_helpers.dart';
import '/core/widgets/buttons/primary_button.dart';

// Feature imports:
import '/features/room/domain/entities/room_entity.dart';
import '/features/room/presentation/blocs/room_bloc.dart';
import '/features/room/presentation/widgets/room_settings_form.dart';

/// Host-only bottom sheet for editing [RoomSettingsEntity] mid-lobby.
/// Dispatches [RoomUpdateSettingsEvent] on save; the updated room comes
/// back through the same watch stream everyone else's client uses, so
/// this sheet doesn't need to optimistically update anything itself.
class EditSettingsSheet extends StatefulWidget {
  const EditSettingsSheet({super.key, required this.room});

  final RoomEntity room;

  @override
  State<EditSettingsSheet> createState() => _EditSettingsSheetState();
}

class _EditSettingsSheetState extends State<EditSettingsSheet> {
  late List<String> _miniGameRotation = List.of(
    widget.room.settings.miniGameRotation,
  );

  void _save() {
    context.read<RoomBloc>().add(
      RoomUpdateSettingsEvent(
        settings: widget.room.settings.copyWith(
          miniGameRotation: _miniGameRotation,
        ),
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.md,
        AppSpacing.xl,
        bottomInset + AppSpacing.xxl,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.borderDefault,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.l10n.roomSettings,
                  style: AppTypography.titleMedium.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.close_rounded,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),
            RoomSettingsForm(
              showVisibilitySelector: false,
              visibility: widget.room.visibility,
              onVisibilityChanged: (_) {},
              miniGameRotation: _miniGameRotation,
              onMiniGameRotationChanged: (v) =>
                  setState(() => _miniGameRotation = v),
            ),
            const SizedBox(height: AppSpacing.massive),
            BlocSelector<RoomBloc, RoomState, bool>(
              selector: (state) => state.isLoading,
              builder: (context, isLoading) => SafeArea(
                child: PrimaryButton(
                  isLoading: isLoading,
                  label: context.l10n.saveChanges,
                  onPressed: _miniGameRotation.isNotEmpty ? _save : null,
                  icon: Icons.stadium_rounded,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
