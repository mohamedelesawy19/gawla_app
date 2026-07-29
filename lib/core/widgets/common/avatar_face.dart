// Package imports:
import 'package:flutter/material.dart';

// Core imports:
import '/core/design_system/colors.dart';
import '/core/design_system/typography.dart';
import '/core/widgets/common/image_widget.dart';

class AvatarFace extends StatelessWidget {
  const AvatarFace({
    super.key,
    required this.avatarUrl,
    required this.initials,
    this.initialsSize = 14,
  });

  final String? avatarUrl;
  final String initials;
  final double initialsSize;

  @override
  Widget build(BuildContext context) {
    final presetGradient = resolveAvatarPreset(avatarUrl);
    if (presetGradient != null) {
      return _InitialsFace(
        initials,
        initialsSize: initialsSize,
        gradient: presetGradient,
      );
    }

    final url = avatarUrl;
    if (url != null && url.isNotEmpty) {
      return ImageWidget(
        src: url,
        errorWidget: _InitialsFace(initials, initialsSize: initialsSize),
      );
    }
    return _InitialsFace(initials, initialsSize: initialsSize);
  }

  bool isAvatarPreset(String? avatarUrl) =>
      avatarUrl != null && avatarUrl.startsWith('preset:');

  List<Color>? resolveAvatarPreset(String? avatarUrl) =>
      isAvatarPreset(avatarUrl)
      ? AppColors.avatarPresetGradients[avatarUrl]
      : null;
}

class _InitialsFace extends StatelessWidget {
  const _InitialsFace(this.initials, {this.initialsSize = 14, this.gradient});

  final String initials;
  final double initialsSize;
  final List<Color>? gradient;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors:
              gradient ?? [AppColors.surfaceElevated, AppColors.surfaceDefault],
        ),
      ),
      child: Center(
        child: Text(
          initials,
          style: AppTypography.headlineSmall.copyWith(
            fontSize: initialsSize,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
