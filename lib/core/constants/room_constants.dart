abstract final class RoomConstants {
  // ── Room-code generation ─────────────────────────────────────────────────

  static const int codeLength = 6;
  static const int maxCodeGenerationRetries = 5;

  /// Only uppercase letters + digits so codes are easy to read and type.
  static const String codeCharset = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';

  // ── Business rules ────────────────────────────────────────────────────────

  static const int maxPlayersPerRoom = 100;
  static const int minPlayersToStart = 2;

  /// How many of the oldest waiting public rooms
  /// inspects before giving up and reporting none available.
  static const int openRoomSearchBatchSize = 10;
}
