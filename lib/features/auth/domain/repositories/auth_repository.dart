// Packages imports:
import 'package:dartz/dartz.dart';

// Core imports:
import '/core/errors/failures.dart';

// Feature imports:
import '/features/auth/domain/entities/auth_user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, void>> signInWithGoogle();
  Future<Either<Failure, void>> signInAnonymously();
  Future<Either<Failure, void>> signOut();
  Future<Either<Failure, AuthUserEntity>> getCurrentUser();
  Stream<AuthUserEntity?> watchAuthState();
}
