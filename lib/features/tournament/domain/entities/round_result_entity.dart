// Package imports:
import 'package:equatable/equatable.dart';

/// One player's outcome for a single round.
///
/// [score] is a *normalized, comparable* value already resolved
/// server-side from whatever raw payload the mini-game submitted
/// (reaction ms, correct-answer count, WPM, ...). The Tournament feature never
/// interprets mini-game-specific units itself — see
/// `SubmitRoundResultParams.payload` in `tournament_repository.dart` for the
/// write side of this boundary. This is the same "plain id instead of a
/// typed dependency" trick `RoomSettingsEntity.miniGameRotation` already
/// uses to stay decoupled from the Mini Games feature.
class RoundResultEntity extends Equatable {
  const RoundResultEntity({
    required this.uid,
    this.score,
    this.rank,
    required this.eliminated,
    this.submittedAt,
  });

  final String uid;

  /// `null` until the server has scored this submission (or decided the
  /// player timed out).
  final double? score;

  /// 1-based placement within the round, assigned once every player has
  /// either submitted or timed out. `null` until then.
  final int? rank;

  /// Whether this round's outcome eliminated the player.
  final bool eliminated;

  /// `null` means the player did not submit before the round's deadline.
  /// The server treats a missed deadline as the worst possible result for
  /// the round, but the domain layer keeps the distinction visible —
  /// useful for UI copy ("timed out" vs. "lost") and for analytics later.
  final DateTime? submittedAt;

  bool get hasSubmitted => submittedAt != null;

  @override
  List<Object?> get props => [uid, score, rank, eliminated, submittedAt];
}
