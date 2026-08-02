abstract final class RoomConstants {
  // ── Room-code generation ─────────────────────────────────────────────────

  static const int codeLength = 6;
  static const int maxCodeGenerationRetries = 5;

  /// Digits only, making the code easy to read and enter.
  static const String codeCharset = '0123456789';

  // ── Business rules ────────────────────────────────────────────────────────

  static const int maxPlayersPerRoom = 64;
  static const int minPlayersToStart = 2;

  /// How many of the oldest waiting public rooms
  /// inspects before giving up and reporting none available.
  static const int openRoomSearchBatchSize = 10;
}
