// Package imports:
import 'package:flutter/widgets.dart';
import 'package:gawla_app/core/localization/localization_helpers.dart';

// Project imports:
import '/features/mini_games/domain/mini_game_play_args.dart';
import '/features/mini_games/presentation/mini_game_definition.dart';
import '/features/mini_games/presentation/shared/reflex_tap_game_widget.dart';

/// `MINI_GAMES_LIBRARY.md §4.8` — the finale.
///
/// `composite_final_strategy.ts`'s own doc comment already flags its
/// scope: true composition — picking two sub-mechanics sized to the
/// finalist count — is a real follow-up feature, not something to fake.
/// Today `compositeFinal` resolves as a single ranked round with the cut
/// target forced to "all but 1", so this widget's job is only to give
/// that ranked round *some* concrete mechanic, matching the backend's
/// actual (not aspirational) behavior — inventing client-side composition
/// against a server that doesn't support it yet would just be a new
/// parallel-engine risk in a different shape.
///
/// For now the finale reuses the reflex mechanic (tuned tighter, since it
/// needs to stay meaningful with as few as 2–3 players). Swapping this
/// for true composition later — once the backend gains it — only means
/// replacing this one file; `MiniGameHost`/`MiniGameRegistry` don't
/// change.
class BossRoundDefinition implements MiniGameDefinition {
  const BossRoundDefinition();

  @override
  String get gameId => 'boss_round';

  @override
  Widget build(BuildContext context, MiniGamePlayArgs args) {
    return ReflexTapGameWidget(
      args: args,
      promptLabel: context.l10n.bossRoundFinalWaitForGreen,
      triggerLabel: context.l10n.bossRoundTapNow,
      minDelay: const Duration(milliseconds: 800),
      maxDelay: const Duration(milliseconds: 2500),
    );
  }
}
