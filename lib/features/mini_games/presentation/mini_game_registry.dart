// Package imports:
import 'package:flutter/material.dart';

// Project imports:
import '/features/mini_games/domain/mini_game_play_args.dart';
import '/features/mini_games/presentation/mini_game_definition.dart';

/// Looks up the [MiniGameDefinition] for a round's `gameId`. The single
/// place `MiniGameHost` depends on — registering a new mini-game means
/// adding one entry to the list this is built from (see
/// `mini_games_module.dart`), never touching this class, `MiniGameHost`,
/// or anything in the Tournament feature. Mirrors the "one lookup point"
/// role `getMiniGameDefinition()` already plays on the Cloud Functions
/// side (`mini_game_registry.ts`).
class MiniGameRegistry {
  MiniGameRegistry(Iterable<MiniGameDefinition> definitions)
    : _byId = {for (final d in definitions) d.gameId: d};

  final Map<String, MiniGameDefinition> _byId;

  /// Returns the registered definition for [gameId], or a visible
  /// "not implemented yet" placeholder rather than throwing. A mini-game
  /// listed in a room's rotation (`RoomSettingsEntity.miniGameRotation`)
  /// but not yet built client-side should degrade gracefully instead of
  /// crashing an in-progress tournament for every player in the room —
  /// the host should never be able to soft-lock a match by picking a
  /// game the app doesn't support yet.
  MiniGameDefinition definitionFor(String gameId) =>
      _byId[gameId] ?? _UnregisteredMiniGameDefinition(gameId);
}

class _UnregisteredMiniGameDefinition implements MiniGameDefinition {
  const _UnregisteredMiniGameDefinition(this.gameId);

  @override
  final String gameId;

  @override
  Widget build(BuildContext context, MiniGamePlayArgs args) {
    // Deliberately does NOT auto-submit anything on the player's behalf —
    // an unbuilt game should stall visibly (and get force-closed as a
    // no-show by `advanceStaleTournamentRounds` like any other missed
    // submission) rather than silently fabricate a result.
    return Center(
      child: Text(
        '"$gameId" isn\'t available in this version yet.',
        style: Theme.of(context).textTheme.bodyMedium,
        textAlign: TextAlign.center,
      ),
    );
  }
}
