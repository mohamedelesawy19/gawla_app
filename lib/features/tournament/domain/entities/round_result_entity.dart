// Package imports:
import 'package:equatable/equatable.dart';

/// One player's outcome for a single round.
///
/// [score] and [passed] are both *normalized, comparable* values already
/// resolved server-side from whatever raw payload the mini-game submitted
/// (reaction ms, correct-answer count, WPM, RPS choice, ...) — see
/// `SubmitRoundResultParams.payload` in `tournament_repository.dart` for the
/// write side of this boundary. The Tournament feature never interprets
/// mini-game-specific units itself; it only ever reads these two generic
/// fields. This is the same "plain id instead of a typed dependency" trick
/// `RoomSettingsEntity.miniGameRotation` already uses to stay decoupled
/// from the Mini Games feature.
///
/// A round's `MiniGameConfigEntity.eliminationType` determines which of
/// [score]/[passed] is actually meaningful: rank-cutoff and team-loss
/// rounds read [score]; binary-fail, survival-fail, and duel-loser rounds
/// read [passed]. The other field is simply `null` — this entity doesn't
/// try to enforce that split itself, since which one applies is a
/// per-elimination-type fact, not a per-result one.
class RoundResultEntity extends Equatable {
  const RoundResultEntity({
    required this.uid,
    this.score,
    this.passed,
    this.rank,
    required this.eliminated,
    this.submittedAt,
    this.groupId,
    this.metadata,
  });

  final String uid;

  /// `null` until the server has scored this submission, or if this
  /// round's elimination type doesn't use a score at all (see class doc).
  final double? score;

  /// `null` until the server has resolved pass/fail for this submission —
  /// including, for duel rounds, while still awaiting the opponent's
  /// commit — or if this round's elimination type doesn't use pass/fail.
  final bool? passed;

  /// 1-based placement within the round, assigned once the round closes.
  /// Its *scope* (global rank, within-duel, within-team) depends on the
  /// elimination type — always for UI/analytics only, never authoritative
  /// for elimination itself ([eliminated] is).
  final int? rank;

  /// Whether this round's outcome eliminated the player.
  final bool eliminated;

  /// `null` means the player did not submit before the round's deadline.
  /// The server treats a missed deadline as an automatic loss for the
  /// round regardless of elimination type, but the domain layer keeps the
  /// distinction visible — useful for UI copy ("timed out" vs. "lost") and
  /// for analytics later.
  final DateTime? submittedAt;

  /// Which duel pair or team this result belongs to, denormalized from
  /// `TournamentRoundEntity.groupAssignments` at submission time for
  /// convenient display (e.g. a "Team Blue" tag on a result row). `null`
  /// for ungrouped elimination types. Never authoritative — the round's
  /// own `groupAssignments` is.
  final String? groupId;

  /// Game-specific, safe-to-reveal display data set only after this
  /// result is resolved (e.g. both duelists' choices, for a reveal
  /// animation). Deliberately opaque — the Mini Games feature's play
  /// handler for this round's `gameId` is the only thing that interprets
  /// its contents; the Tournament feature never reads into it.
  final Map<String, dynamic>? metadata;

  bool get hasSubmitted => submittedAt != null;

  @override
  List<Object?> get props => [
    uid,
    score,
    passed,
    rank,
    eliminated,
    submittedAt,
    groupId,
    metadata,
  ];
}
