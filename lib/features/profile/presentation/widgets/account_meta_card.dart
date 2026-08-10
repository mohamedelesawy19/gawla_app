// Package imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Core imports:
import '/core/design_system/borders.dart';
import '/core/design_system/colors.dart';
import '/core/design_system/spacing.dart';
import '/core/design_system/typography.dart';
import '/core/localization/localization_helpers.dart';
import '/core/widgets/cards/app_card.dart';
import '/core/widgets/feedback/snackbar.dart';

class AccountMetaCard extends StatelessWidget {
  const AccountMetaCard({
    super.key,
    required this.uid,
    required this.createdAt,
  });

  final String uid;
  final DateTime? createdAt;

  void _copyUid(BuildContext context) {
    Clipboard.setData(ClipboardData(text: uid));
    CustomSnackbar.success(context, 'Player ID copied');
  }

  String get _shortUid => uid.length <= 10 ? uid : '${uid.substring(0, 10)}…';

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: AppColors.surfaceSunken,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (createdAt != null) ...[
            Row(
              children: [
                const Icon(
                  Icons.event_rounded,
                  size: 15,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  context.l10n.playingSince(createdAt!.year),
                  style: AppTypography.caption,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          InkWell(
            borderRadius: BorderRadius.circular(AppBorders.radiusMd),
            onTap: () => _copyUid(context),
            child: Row(
              children: [
                const Icon(
                  Icons.badge_outlined,
                  size: 15,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    context.l10n.playerId(_shortUid),
                    style: AppTypography.code.copyWith(
                      color: AppColors.textTertiary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(
                  Icons.copy_rounded,
                  size: 13,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
