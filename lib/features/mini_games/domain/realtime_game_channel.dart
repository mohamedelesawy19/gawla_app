/// Thin abstraction over a single round's low-latency, server-driven
/// broadcast channel — the piece `binary_fail_games.ts`'s doc comments
/// explicitly call out as owned by the Mini Games feature "via its own
/// real-time channel," not something Tournament's end-of-round
/// `submitRoundResult` payload can express (a server-broadcast RED/GREEN
/// switch, a live team power meter — anything that has to update *during*
/// a round, not just be summarized at the end of it).
///
/// IMPORTANT — backend counterpart required: the schema under
/// `channelPath` (e.g. `miniGameChannels/{tournamentId}/{roundIndex}/{gameId}`)
/// is game-specific and owned by whichever Cloud Function drives that
/// game's real-time mechanic (a `driveFreezeFrenzyRound` /
/// `driveTugOfPowerRound` style trigger). Those driver functions are a
/// genuine new backend surface this Flutter feature depends on but does
/// not implement — see ARCHITECTURE.md's "Backend follow-ups" section
/// for the exact contract each game widget below expects. This class
/// only standardizes how a widget talks to that path from the client
/// side, so every real-time game shares one implementation instead of
/// each hand-rolling its own RTDB wiring.
///
/// Security: `pushEvent` writes MUST be constrained by RTDB rules so a
/// player can only write to their own uid's slot under a channel — the
/// same "never trust the client, only its input" boundary
/// `PROJECT_OVERVIEW.md`'s anti-cheat table already applies everywhere
/// else. This is a rules change outside this file's scope, flagged the
/// same way `DUEL_COMMITS_SUBCOLLECTION`'s doc comment flags its own
/// required Firestore rule.
abstract class RealtimeGameChannel {
  /// Server-pushed state for this round, decoded from whatever shape the
  /// backing Cloud Function writes at `channelPath`. Never assume the
  /// first event arrives instantly — render a neutral/loading state
  /// until it does, the same way `TournamentRoundTimer` never assumes
  /// `startedAt`/`endsAt` are populated before a round is truly active.
  Stream<Map<String, dynamic>> watch(String channelPath);

  /// Pushes a client-originated input event (e.g. "I'm holding the move
  /// button", "I picked the left tile") for the server-side driver
  /// function to timestamp and validate. This is NOT the round result —
  /// it's raw input the server uses while the round is live. The client
  /// still calls `MiniGamePlayArgs.onSubmit` separately once the
  /// mechanic concludes, exactly like every other mini-game.
  Future<void> pushEvent(String channelPath, Map<String, dynamic> event);
}
