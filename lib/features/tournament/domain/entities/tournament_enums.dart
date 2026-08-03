/// Lifecycle of a single tournament (the full elimination tournament run for a
/// room) — everything from `RoomStatus.inProgress` through the Winner
/// Screen in the tournament flow.
///
/// This looks similar to [RoomStatus] but answers a different question on
/// purpose: `RoomStatus` only records *whether a tournament exists* for a room
/// (Room feature's concern — it flips to `inProgress` once, atomically,
/// when the tournament is created, and never changes again for that room).
/// [TournamentStatus] records *how that tournament's rounds are progressing*
/// (Tournament feature's concern). Keeping them on separate documents avoids
/// two features racing to own the same fact.
enum TournamentStatus {
  /// Tournament document exists, first round has not gone live yet (e.g. a
  /// short "get ready" beat while players load into the mini-game).
  starting,

  /// A round is pending, active, or being scored.
  inProgress,

  /// A winner has been determined; `TournamentEntity.winnerUid` is set.
  completed,

  /// Ended early without a winner (e.g. every remaining player
  /// disconnected). Terminal, like [completed].
  cancelled,
}

/// Lifecycle of a single round within a tournament.
enum RoundStatus {
  /// Not yet the active round.
  pending,

  /// Currently accepting result submissions.
  active,

  /// Submissions closed and eliminations for this round have been
  /// applied.
  completed,
}

/// A player's standing within a single tournament. Distinct from
/// `RoomPlayerEntity`, which only tracks lobby presence and knows nothing
/// about rounds or eliminations.
enum TournamentPlayerStatus {
  /// Still competing in the current or a future round.
  active,

  /// Cut in a previous round; may still watch the tournament play out
  /// (spectator mode builds on this for free — no domain change needed).
  eliminated,

  /// The single player left active when the tournament reached
  /// [TournamentStatus.completed].
  winner,
}
