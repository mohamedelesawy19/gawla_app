import 'package:flutter/material.dart';

/// A single progression tier shown on the profile's milestone strip.
///
/// This is presentation-only flavor: every tier is derived purely from the
/// player's existing `level` field. Nothing here is fetched or persisted —
/// it's a static lookup table, the same way a client might render "bronze /
/// silver / gold" ranks from a numeric score without the server knowing
/// what a "rank name" is.
class MilestoneTier {
  const MilestoneTier({
    required this.minLevel,
    required this.id,
    required this.icon,
  });

  final int minLevel;
  final MilestoneTierId id;
  final IconData icon;
}

enum MilestoneTierId { rookie, contender, risingStar, champion, elite, legend }

abstract final class MilestoneTiers {
  static const List<MilestoneTier> all = [
    MilestoneTier(
      minLevel: 1,
      id: MilestoneTierId.rookie,
      icon: Icons.flag_rounded,
    ),
    MilestoneTier(
      minLevel: 5,
      id: MilestoneTierId.contender,
      icon: Icons.bolt_rounded,
    ),
    MilestoneTier(
      minLevel: 10,
      id: MilestoneTierId.risingStar,
      icon: Icons.auto_awesome_rounded,
    ),
    MilestoneTier(
      minLevel: 20,
      id: MilestoneTierId.champion,
      icon: Icons.emoji_events_rounded,
    ),
    MilestoneTier(
      minLevel: 35,
      id: MilestoneTierId.elite,
      icon: Icons.military_tech_rounded,
    ),
    MilestoneTier(
      minLevel: 50,
      id: MilestoneTierId.legend,
      icon: Icons.workspace_premium_rounded,
    ),
  ];

  /// Returns the highest unlocked milestone tier for the given player level.
  static MilestoneTier currentFor(int level) {
    var current = all.first;
    for (final tier in all) {
      if (level >= tier.minLevel) current = tier;
    }
    return current;
  }
}
