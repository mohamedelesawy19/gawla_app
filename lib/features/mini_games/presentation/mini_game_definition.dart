// Package imports:
import 'package:flutter/widgets.dart';

// Feature imports:
import '/features/mini_games/domain/mini_game_play_args.dart';

/// One implementation per mini-game id — the Flutter-side counterpart of
/// the Cloud Functions `MiniGameDefinition`
/// (`functions/src/mini_games/mini_game_definition.dart`'s `.ts`
/// original). Where the backend definition turns a raw payload into
/// `{score, passed}`, this definition turns a [MiniGamePlayArgs] into the
/// actual gameplay widget that *produces* that raw payload in the first
/// place.
///
/// This is the single seam that makes "adding a new mini-game" a
/// registration, not a modification: `MiniGameHost` and `MiniGameRegistry`
/// never branch on `gameId` themselves — they only ever call through this
/// interface. See `mini_games_module.dart` for where new implementations
/// get registered.
abstract class MiniGameDefinition {
  /// Matches `MINI_GAMES_LIBRARY.md`'s ID column and the Cloud Functions
  /// registry key exactly — must equal `MiniGameConfigEntity.gameId` /
  /// `TournamentRoundEntity.miniGameId` for whichever mini-game this
  /// implements.
  String get gameId;

  /// Builds the interactive gameplay surface for one round of this game.
  /// Implementations own their own local state (typically a
  /// `StatefulWidget`) but must never submit a result the player didn't
  /// actually produce, and must call `args.onSubmit` at most once per
  /// round — `MiniGameHost` re-keys this widget per round precisely so
  /// implementations don't have to guard against stale double-submits
  /// across rounds themselves.
  Widget build(BuildContext context, MiniGamePlayArgs args);
}
