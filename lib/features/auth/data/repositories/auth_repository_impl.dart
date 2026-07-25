// Package imports:
import 'package:dartz/dartz.dart';

// Core imports:
import '/core/errors/exceptions.dart';
import '/core/errors/failures.dart';

// Features imports:
import '/features/auth/data/datasources/auth_remote_datasource.dart';
import '/features/auth/domain/entities/auth_user_entity.dart';
import '/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remote);

  final AuthRemoteDataSource _remote;

  @override
  Future<Either<Failure, void>> signInWithGoogle() async {
    try {
      await _remote.signInWithGoogle();
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on Exception catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signInAnonymously() async {
    try {
      await _remote.signInAnonymously();
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on Exception catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _remote.signOut();
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on Exception catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthUserEntity>> getCurrentUser() async {
    try {
      final model = await _remote.getCurrentUser();
      return Right(model.toEntity());
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on Exception catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Stream<AuthUserEntity?> watchAuthState() {
    return _remote.watchAuthState().map((model) => model?.toEntity());
  }
}
