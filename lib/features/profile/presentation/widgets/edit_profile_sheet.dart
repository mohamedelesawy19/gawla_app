// Package imports:
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Core imports:
import '/core/design_system/borders.dart';
import '/core/design_system/colors.dart';
import '/core/design_system/spacing.dart';
import '/core/design_system/typography.dart';
import '/core/localization/localization_helpers.dart';
import '/core/theme/theme_extensions.dart';
import '/core/utils/string_utils.dart';
import '/core/widgets/buttons/primary_button.dart';

// Features imports:
import '/features/profile/domain/entities/player_entity.dart';
import '/features/profile/presentation/blocs/profile_bloc.dart';
import '/features/profile/presentation/widgets/trophy_ring_avatar.dart';

Future<void> showEditProfileSheet(
  BuildContext context, {
  required PlayerEntity profile,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => BlocProvider.value(
      value: context.read<ProfileBloc>(),
      child: EditProfileSheet(profile: profile),
    ),
  );
}

class EditProfileSheet extends StatefulWidget {
  const EditProfileSheet({super.key, required this.profile});

  final PlayerEntity profile;

  @override
  State<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<EditProfileSheet> {
  late final TextEditingController _nameController = TextEditingController(
    text: widget.profile.displayName,
  );
  late String? _selectedAvatarUrl = widget.profile.avatarUrl;
  bool _submitted = false;

  bool get _nameValid => _nameController.text.trim().isNotEmpty;

  bool get _hasChanges =>
      _nameController.text.trim() != widget.profile.displayName ||
      _selectedAvatarUrl != widget.profile.avatarUrl;

  void _save() {
    if (!_nameValid || !_hasChanges) return;
    setState(() => _submitted = true);
    context.read<ProfileBloc>().add(
      UpdateProfileEvent(
        uid: widget.profile.uid,
        displayName: _nameController.text.trim(),
        avatarUrl: _selectedAvatarUrl,
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (!_submitted) return;
        if (state is ProfileLoaded) {
          Navigator.of(context).pop();
        } else if (state is ProfileError) {
          setState(() => _submitted = false);
        }
      },
      builder: (context, state) {
        final isSaving = state is ProfileUpdating;
        final hasError = state is ProfileError && _submitted;

        return Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.md,
            AppSpacing.xl,
            bottomInset + AppSpacing.xxl,
          ),
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
                    context.l10n.editProfile,
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
              const SizedBox(height: AppSpacing.md),
              Center(
                child: TrophyRingAvatar(
                  size: 96,
                  progress: 1,
                  level: widget.profile.level,
                  initials: StringUtils.initials(_nameController.text),
                  avatarUrl: _selectedAvatarUrl,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(context.l10n.avatarStyle, style: AppTypography.labelMedium),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                height: 52,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: AppColors.avatarPresetGradients.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(width: AppSpacing.md),
                  itemBuilder: (context, index) {
                    final entry = AppColors.avatarPresetGradients.entries
                        .elementAt(index);
                    final selected = _selectedAvatarUrl == entry.key;
                    return GestureDetector(
                      onTap: () =>
                          setState(() => _selectedAvatarUrl = entry.key),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(colors: entry.value),
                          border: Border.all(
                            color: selected ? Colors.white : Colors.transparent,
                            width: 2.5,
                          ),
                        ),
                        child: selected
                            ? const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 18,
                              )
                            : null,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(context.l10n.displayName, style: AppTypography.labelMedium),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _nameController,
                maxLength: 20,
                style: AppTypography.bodyLarge.copyWith(
                  height: 1.35,
                  fontWeight: FontWeight.w500,
                ),
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.surfaceSunken,
                  counterStyle: AppTypography.caption,
                  contentPadding: AppSpacing.paddingLg,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppBorders.radiusXl),
                    borderSide: const BorderSide(color: AppColors.borderSubtle),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppBorders.radiusXl),
                    borderSide: const BorderSide(color: AppColors.brandPrimary),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppBorders.radiusXl),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              if (hasError) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  context.l10n.couldNotSaveChanges,
                  style: AppTypography.caption.copyWith(
                    color: context.colorScheme.error,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              PrimaryButton(
                label: context.l10n.saveChanges,
                isLoading: isSaving,
                icon: Icons.check_circle_rounded,
                onPressed: (_nameValid && _hasChanges && !isSaving)
                    ? _save
                    : null,
              ),
            ],
          ),
        );
      },
    );
  }
}
