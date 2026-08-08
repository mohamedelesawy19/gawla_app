// Package imports:
import 'package:flutter/widgets.dart';

// Core imports:
import '/core/localization/localization_helpers.dart';

// Project imports:
import '/features/mini_games/domain/mini_game_play_args.dart';
import '/features/mini_games/presentation/mini_game_definition.dart';
import '/features/mini_games/presentation/shared/reflex_tap_game_widget.dart';

/// `MINI_GAMES_LIBRARY.md §3.1`. This is the whole definition — every
/// other mechanic is already handled by `ReflexTapGameWidget`.
///
/// `ColorChallengeDefinition` and `MusicalFreezeDefinition` (Tier
/// A/B siblings — `§3.5`, `§4.3`) follow the identical shape: wrap
/// `ReflexTapGameWidget` with their own copy/timing and register under
/// their own `gameId`. Left unregistered for now — see
/// ARCHITECTURE.md's extension guide.
class ReactionTapDefinition implements MiniGameDefinition {
  const ReactionTapDefinition();

  @override
  String get gameId => 'reaction_tap';

  @override
  Widget build(BuildContext context, MiniGamePlayArgs args) {
    return ReflexTapGameWidget(
      args: args,
      promptLabel: context.l10n.reactionTapWaitForGreen,
      triggerLabel: context.l10n.reactionTapTap,
    );
  }
}
