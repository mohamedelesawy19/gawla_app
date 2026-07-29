// Package imports:
import 'package:dartz/dartz.dart';

// Core imports:
import '/core/errors/failures.dart';
import '/core/services/current_player/current_player.dart';

/// Answers a single question: "who is acting right now?"
/// Room/Match/Chat use cases depend on this, never on AuthRepository
/// or ProfileRepository directly — they don't know or care where
/// identity data actually comes from.
abstract interface class CurrentPlayerService {
  Future<Either<Failure, CurrentPlayer>> getCurrentPlayer();
  Future<Either<Failure, String>> getCurrentUid();
}
