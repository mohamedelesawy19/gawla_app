// Package imports:
import 'package:dartz/dartz.dart';

// Core imports:
import '/core/errors/failures.dart';

// Feature imports:
import '/features/profile/domain/entities/player_entity.dart';

abstract class ProfileRepository {
  Future<Either<Failure, PlayerEntity>> getProfile(String uid);
  Future<Either<Failure, void>> updateProfile({
    required String uid,
    String? displayName,
    String? avatarUrl,
  });
}
