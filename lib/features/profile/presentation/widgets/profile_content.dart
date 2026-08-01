// Package imports:
import 'package:flutter/material.dart';

// Core imports:
import '/core/design_system/spacing.dart';

// Features imports:
import '/features/profile/domain/entities/player_entity.dart';
import '/features/profile/domain/services/level_system.dart';
import '/features/profile/domain/services/player_initials.dart';
import '/features/profile/presentation/widgets/account_meta_card.dart';
import '/features/profile/presentation/widgets/milestone_strip.dart';
import '/features/profile/presentation/widgets/profile_hero_header.dart';
import '/features/profile/presentation/widgets/wallet_row.dart';

class ProfileContent extends StatelessWidget {
  const ProfileContent({
    super.key,
    required this.profile,
    required this.isSaving,
    required this.onEditTap,
    required this.onLogoutTap,
    required this.onRefresh,
  });

  final PlayerEntity profile;
  final bool isSaving;
  final VoidCallback onEditTap;
  final VoidCallback onLogoutTap;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          SliverToBoxAdapter(
            child: ProfileHeroHeader(
              displayName: profile.displayName,
              initials: profile.initials,
              avatarUrl: profile.avatarUrl,
              level: profile.level,
              levelProgress: profile.levelProgress,
              isSaving: isSaving,
              onEditTap: onEditTap,
              onLogoutTap: onLogoutTap,
            ),
          ),
          SliverList.list(
            children: [
              const SizedBox(height: AppSpacing.xl),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: WalletRow(coins: profile.coins, gems: profile.gems),
              ),
              const SizedBox(height: AppSpacing.xxl),
              MilestoneStrip(level: profile.level),
              const SizedBox(height: AppSpacing.xxl),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: AccountMetaCard(
                  uid: profile.uid,
                  createdAt: profile.createdAt,
                ),
              ),
              const SizedBox(height: AppSpacing.huge),
            ],
          ),
        ],
      ),
    );
  }
}
