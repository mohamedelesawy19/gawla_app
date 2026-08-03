// Package imports:
import 'package:flutter/material.dart';

// Core imports:
import '/core/design_system/colors.dart';
import '/core/design_system/spacing.dart';

// Feature imports:
import '/features/room/domain/entities/room_enums.dart';
import '/features/room/presentation/widgets/room_code_banner.dart';

class RoomHeroBackground extends StatelessWidget {
  const RoomHeroBackground({
    super.key,
    required this.visibility,
    required this.inviteCode,
  });

  final RoomVisibility visibility;
  final String? inviteCode;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.brandPrimaryDark, AppColors.backgroundPrimary],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: -44,
            right: -28,
            child: _AmbientBlob(
              color: AppColors.brandPrimary.withValues(alpha: 0.16),
              size: 168,
            ),
          ),
          Positioned(
            top: -56,
            left: -24,
            child: _AmbientBlob(
              color: AppColors.brandPrimary.withValues(alpha: 0.1),
              size: 148,
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 8, bottom: 4),
              child: Icon(
                Icons.emoji_events_rounded,
                size: 104,
                color: AppColors.iconDefault.withValues(alpha: 0.06),
              ),
            ),
          ),
          if (visibility == RoomVisibility.private && inviteCode != null)
            Padding(
              padding: AppSpacing.paddingXl,
              child: Align(
                alignment: Alignment.bottomLeft,
                child: RoomCodeBanner(inviteCode: inviteCode!),
              ),
            ),
        ],
      ),
    );
  }
}

/// A soft, unfocused circle of color — ambient texture only, never a
/// container for content, so it never fights with what's drawn on top.
class _AmbientBlob extends StatelessWidget {
  const _AmbientBlob({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
