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

/// How a round's `MiniGameConfigEntity` decides who's cut, per
/// `MINI_GAMES_LIBRARY.md §1`'s elimination taxonomy. This is what makes
/// elimination pluggable per mini-game instead of one formula applying to
/// every round — see that doc's taxonomy table for the full rationale
/// behind each member.
///
/// Resolution of *which* players are eliminated always happens server-side
/// (Cloud Functions' `EliminationStrategy` registry — never the client, per
/// the project's anti-cheat rules). This enum exists on the Flutter side
/// purely so the Tournament and Mini Games features can *interpret* round
/// state — e.g. deciding which widget to render, or showing a "Team Blue"
/// badge — not to compute eliminations themselves.
enum EliminationType {
  /// Players ranked by score/time; bottom X% or bottom N eliminated.
  rankCutoff,

  /// One wrong action/choice = instant elimination, no ranking needed.
  binaryFail,

  /// Players paired 1v1; losers of each pairing eliminated.
  duelLoser,

  /// Must maintain a state for the full round duration; failing at any
  /// point = out.
  survivalFail,

  /// Two teams compete; the losing team (or its weakest contributors) is
  /// eliminated.
  teamLoss,

  /// Finale-only: mixes mechanics, resolves to a single winner.
  compositeFinal,
}

/// Whether a round's `EliminationTargetEntity.value` is an absolute
/// headcount or a fraction of the active pool.
enum EliminationTargetKind { count, percentage }
