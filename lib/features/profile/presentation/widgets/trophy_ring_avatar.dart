// Dart imports:
import 'dart:math' as math;

// Package imports:
import 'package:flutter/material.dart';

// Core imports:
import '/core/design_system/colors.dart';
import '/core/design_system/typography.dart';
import '/core/widgets/common/avatar_face.dart';

class TrophyRingAvatar extends StatelessWidget {
  const TrophyRingAvatar({
    super.key,
    required this.progress,
    required this.level,
    required this.initials,
    this.avatarUrl,
    this.size = 124,
    this.isSaving = false,
    this.onTap,
  });

  final double progress;
  final int level;
  final String initials;
  final String? avatarUrl;
  final double size;
  final bool isSaving;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    const medalSize = 38.0;
    final frameSize = size + 12; // room for tick marks outside the avatar

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: frameSize,
        height: frameSize + medalSize * 0.45,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            // Ambient spotlight glow, evoking a stage at the center of the
            // arena rather than a flat drop shadow.
            Container(
              width: frameSize,
              height: frameSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.brandAccentBlazeStart.withValues(
                      alpha: 0.28,
                    ),
                    blurRadius: 40,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
            CustomPaint(
              size: Size.square(frameSize),
              painter: _ArenaBezelPainter(progress: progress.clamp(0.0, 1.0)),
            ),
            Padding(
              padding: const EdgeInsets.all(7),
              child: ClipOval(
                child: SizedBox(
                  width: size - 14,
                  height: size - 14,
                  child: AvatarFace(
                    avatarUrl: avatarUrl,
                    initials: initials,
                    initialsSize: 30,
                  ),
                ),
              ),
            ),
            if (isSaving)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceElevated,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(5),
                  child: const CircularProgressIndicator(
                    strokeWidth: 2.2,
                    valueColor: AlwaysStoppedAnimation(AppColors.currencyCoin),
                  ),
                ),
              ),
            // Level medal, pinned at the base of the ring like an award.
            Positioned(
              bottom: 0,
              child: Container(
                width: medalSize,
                height: medalSize,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.brandAccentBlazeGradient,
                  border: Border.all(
                    color: AppColors.backgroundPrimary,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.brandAccentBlazeStart.withValues(
                        alpha: 0.45,
                      ),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  '$level',
                  style: AppTypography.titleMedium.copyWith(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    height: 1.0,
                  ),
                  semanticsLabel: 'Level $level',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArenaBezelPainter extends CustomPainter {
  const _ArenaBezelPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final tickRadius = size.width / 2 - 2;
    final ringRadius = size.width / 2 - 9;

    // Stopwatch-bezel tick marks — quiet texture, not the focal point.
    const tickCount = 60;
    for (var i = 0; i < tickCount; i++) {
      final isMajor = i % 5 == 0;
      final angle = (2 * math.pi / tickCount) * i - math.pi / 2;
      final length = isMajor ? 6.0 : 3.0;
      final start = Offset(
        center.dx + tickRadius * math.cos(angle),
        center.dy + tickRadius * math.sin(angle),
      );
      final end = Offset(
        center.dx + (tickRadius - length) * math.cos(angle),
        center.dy + (tickRadius - length) * math.sin(angle),
      );
      final tickPaint = Paint()
        ..color = isMajor
            ? AppColors.textTertiary.withValues(alpha: 0.55)
            : AppColors.borderDefault.withValues(alpha: 0.5)
        ..strokeWidth = isMajor ? 1.6 : 1.1
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(start, end, tickPaint);
    }

    // Full track.
    final trackPaint = Paint()
      ..color = AppColors.borderDefault.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, ringRadius, trackPaint);

    // Progress arc, diagonal Victory Blaze shader across the ring's bounds.
    if (progress > 0) {
      final rect = Rect.fromCircle(center: center, radius: ringRadius);
      final arcPaint = Paint()
        ..shader = AppColors.brandAccentBlazeGradient.createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.5
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        rect,
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        arcPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ArenaBezelPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
