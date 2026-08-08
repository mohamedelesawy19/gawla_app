// Package imports:
import 'package:firebase_database/firebase_database.dart';

// Core imports:
import '/core/di/service_locator.dart';

// Features imports:
import '/features/mini_games/data/firebase_realtime_game_channel.dart';
import '/features/mini_games/domain/realtime_game_channel.dart';
import '/features/mini_games/presentation/games/boss_round_game.dart';
import '/features/mini_games/presentation/games/odd_one_out_game.dart';
import '/features/mini_games/presentation/games/reaction_tap_game.dart';
import '/features/mini_games/presentation/mini_game_registry.dart';

class MiniGamesModule {
  const MiniGamesModule._();

  static void register() {
    ServiceLocator.registerLazySingleton<RealtimeGameChannel>(
      () => FirebaseRealtimeGameChannel(FirebaseDatabase.instance),
    );

    ServiceLocator.registerLazySingleton<MiniGameRegistry>(
      () => MiniGameRegistry([
        const ReactionTapDefinition(),
        const OddOneOutDefinition(),
        const BossRoundDefinition(),
        // Not yet ported — each falls through to
        // `MiniGameRegistry`'s "not available yet" placeholder until
        // built, rather than crashing a tournament that rotates one of
        // them in. See ARCHITECTURE.md's extension guide for how little
        // work each of these is expected to take given the shared base
        // widgets above:
        //   color_challenge, musical_freeze  -> ReflexTapGameWidget
        //   memory_cards, sequence_order,
        //   speed_typing, find_the_difference,
        //   hidden_object                    -> bespoke, own interaction
        //   tile_trap                        -> same shape as
        //                                        freeze_frenzy_game.dart
        //   steady_hands                     -> continuous local
        //                                        sampling + sensors_plus
        //   trace_the_shape                  -> bespoke, path tracing
      ]),
    );
  }
}
