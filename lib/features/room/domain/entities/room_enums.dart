/// Who can join the room.
enum RoomVisibility { public, private }

/// Lifecycle of a room.
///
/// Kept intentionally small — the Room feature only owns the *lobby*.
/// The round-by-round tournament state machine belongs to the future
/// Tournament feature; this room simply flips to [inProgress] once a
/// match exists for it and [SessionBloc]'s match subscription takes over.
enum RoomStatus {
  /// Accepting players, tournament has not started.
  waiting,

  /// Tournament has started, but the first round has not yet begun.
  starting,

  /// A match has been created for this room; no longer joinable.
  inProgress,

  /// Room finished or was cancelled and is no longer active.
  closed,
}
