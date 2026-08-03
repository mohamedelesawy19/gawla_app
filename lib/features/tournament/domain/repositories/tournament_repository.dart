// Package imports:
import 'package:dartz/dartz.dart';

// Core imports:
import '/core/errors/failures.dart';

// Feature imports:
import '/features/tournament/domain/entities/tournament_entity.dart';

/// Data-access boundary for the Tournament feature.
///
/// Every mutation here funnels through server-authoritative logic (Cloud
/// Functions) per the project's anti-cheat rules — this interface never
/// exposes a way to write scored results or eliminations directly. The
/// client only ever (a) asks the server to start a tournament, (b) submits raw
/// round data for the server to score, and (c) watches the resulting
/// state.
abstract interface class TournamentRepository {
  /// Emits the id of the currently active tournament for [roomId], or `null`
  /// if the room has no tournament in progress. Wired into `SessionBloc` at
  /// the composition root as its `WatchTournamentId` implementation — this is
  /// the piece `SessionBloc`'s doc comment refers to as "implemented
  /// later by the Tournament feature".
  Stream<String?> watchTournamentIdForRoom(String roomId);

  /// Realtime stream of [tournamentId]'s full state, or `null` if the
  /// tournament no longer exists.
  Stream<TournamentEntity?> watchTournament(String tournamentId);

  /// Host-only: creates a tournament for a room from its current player list
  /// and `RoomSettingsEntity.miniGameRotation`, snapshotting both
  /// server-side. Returns the new tournament's id.
  ///
  /// Host verification and the room-status flip to `RoomStatus.
  /// inProgress` happen atomically server-side as part of this call —
  /// the Tournament feature never writes to Room's data directly.
  Future<Either<Failure, String>> startTournament(String roomId);

  /// Submits this player's raw result payload for a round. The server
  /// scores it, applies plausibility checks, and folds the outcome into
  /// the stream from [watchTournament] — the return value here only reflects
  /// whether the submission was accepted, never the scored outcome.
  Future<Either<Failure, Unit>> submitRoundResult({
    required String tournamentId,
    required int roundIndex,
    required Map<String, dynamic> payload,
  });
}
