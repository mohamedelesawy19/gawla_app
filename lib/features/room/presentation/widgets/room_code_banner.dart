// Package imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Core imports:
import '/core/design_system/colors.dart';
import '/core/localization/localization_helpers.dart';
import '/core/theme/theme_extensions.dart';
import '/core/widgets/feedback/snackbar.dart';

class RoomCodeBanner extends StatelessWidget {
  const RoomCodeBanner({super.key, required this.inviteCode});

  final String inviteCode;

  Future<void> _copy(BuildContext context) async {
    await HapticFeedback.selectionClick();
    await Clipboard.setData(ClipboardData(text: inviteCode));
    if (context.mounted) {
      CustomSnackbar.success(context, context.l10n.inviteCodeCopied);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(20)),
      child: Material(
        color: AppColors.brandSecondaryLight.withValues(alpha: 0.3),
        child: InkWell(
          onTap: () => _copy(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.lock_rounded,
                  size: 18,
                  color: AppColors.textPrimary,
                ),
                const SizedBox(width: 10),
                Text(
                  inviteCode,
                  style: context.textTheme.titleMedium?.copyWith(
                    letterSpacing: 4,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 14),
                SizedBox(
                  height: 24,
                  width: 1,
                  child: CustomPaint(
                    painter: _DashedDividerPainter(
                      color: AppColors.textPrimary.withValues(alpha: 0.35),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                const Icon(
                  Icons.copy_rounded,
                  size: 16,
                  color: AppColors.textPrimary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The ticket's perforated tear-line, separating the code from its
/// tap-to-copy stub.
class _DashedDividerPainter extends CustomPainter {
  const _DashedDividerPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.4;
    const dashHeight = 4.0;
    const dashGap = 4.0;
    var y = 0.0;
    while (y < size.height) {
      canvas.drawLine(Offset(0, y), Offset(0, y + dashHeight), paint);
      y += dashHeight + dashGap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedDividerPainter oldDelegate) =>
      oldDelegate.color != color;
}
