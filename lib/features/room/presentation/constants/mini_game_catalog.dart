// Package imports:
import 'package:flutter/material.dart';

/// One entry in the static MVP mini-game catalog.
class MiniGameCatalogEntry {
  const MiniGameCatalogEntry({
    required this.id,
    required this.label,
    required this.icon,
  });

  /// Matches an id in [RoomSettingsEntity.miniGameRotation] — the domain
  /// layer treats these as opaque strings, so this catalog is the only
  /// place that knows their display labels/icons.
  final String id;
  final String label;
  final IconData icon;
}

/// Static, presentation-only catalog of the MVP mini-games from the
/// project overview's "Mini-Games" table.
///
/// This intentionally does NOT belong to the domain layer: it's UI
/// display metadata (labels, icons) for ids that
/// [RoomSettingsEntity.miniGameRotation] already stores as plain
/// strings. Once a real Mini Games feature exists with its own
/// catalog use case, this file should be deleted in favor of that.
abstract final class MiniGameCatalog {
  static const List<MiniGameCatalogEntry> mvpSet = [
    MiniGameCatalogEntry(
      id: 'reaction_tap',
      label: 'Reaction Tap',
      icon: Icons.bolt_rounded,
    ),
    MiniGameCatalogEntry(
      id: 'quick_trivia',
      label: 'Quick Trivia',
      icon: Icons.quiz_rounded,
    ),
    MiniGameCatalogEntry(
      id: 'memory_cards',
      label: 'Memory Cards',
      icon: Icons.grid_view_rounded,
    ),
    MiniGameCatalogEntry(
      id: 'find_the_difference',
      label: 'Find the Difference',
      icon: Icons.search_rounded,
    ),
    MiniGameCatalogEntry(
      id: 'color_challenge',
      label: 'Color Challenge',
      icon: Icons.palette_rounded,
    ),
    MiniGameCatalogEntry(
      id: 'math_rush',
      label: 'Math Rush',
      icon: Icons.calculate_rounded,
    ),
    MiniGameCatalogEntry(
      id: 'sequence_order',
      label: 'Sequence Order',
      icon: Icons.format_list_numbered_rounded,
    ),
    MiniGameCatalogEntry(
      id: 'speed_typing',
      label: 'Speed Typing',
      icon: Icons.keyboard_rounded,
    ),
    MiniGameCatalogEntry(
      id: 'true_or_false',
      label: 'True or False',
      icon: Icons.rule_rounded,
    ),
    MiniGameCatalogEntry(
      id: 'hidden_object',
      label: 'Hidden Object',
      icon: Icons.visibility_rounded,
    ),
  ];
}
