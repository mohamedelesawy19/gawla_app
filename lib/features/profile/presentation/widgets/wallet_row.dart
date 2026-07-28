// Package imports:
import 'package:flutter/material.dart';

// Core imports:
import '/core/design_system/colors.dart';
import '/core/design_system/spacing.dart';
import '/core/design_system/typography.dart';
import '/core/localization/localization_helpers.dart';
import '/core/theme/theme_extensions.dart';
import '/core/widgets/cards/app_card.dart';

class WalletRow extends StatelessWidget {
  const WalletRow({
    super.key,
    required this.coins,
    required this.gems,
    this.onTapCoins,
    this.onTapGems,
  });

  final int coins;
  final int gems;
  final VoidCallback? onTapCoins;
  final VoidCallback? onTapGems;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _WalletChip(
            value: coins,
            label: context.l10n.coins,
            icon: '🪙',
            glowColor: AppColors.currencyCoin,
            onTap: onTapCoins,
          ),
        ),
        AppSpacing.horizontalSpaceMd,
        Expanded(
          child: _WalletChip(
            value: gems,
            label: context.l10n.gems,
            icon: '💎',
            glowColor: AppColors.currencyGem,
            onTap: onTapGems,
          ),
        ),
      ],
    );
  }
}

class _WalletChip extends StatelessWidget {
  const _WalletChip({
    required this.value,
    required this.label,
    required this.icon,
    required this.glowColor,
    this.onTap,
  });

  final int value;
  final String label;
  final String icon;
  final Color glowColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: AppCard(
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: glowColor.withValues(alpha: 0.14),
                ),
                child: Center(
                  child: Text(icon, style: const TextStyle(fontSize: 16)),
                ),
              ),
              AppSpacing.horizontalSpaceMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$value',
                      style: context.textTheme.titleLarge!.copyWith(
                        fontWeight: .w700,
                        fontSize: 19,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(label, style: AppTypography.caption),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
