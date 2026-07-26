// Package imports:
import 'package:dartz/dartz.dart';

// Core imports:
import '/core/errors/exceptions.dart';
import '/core/errors/failures.dart';

// Feature imports:
import '/features/profile/data/datasources/profile_remote_datasource.dart';
import '/features/profile/domain/entities/player_entity.dart';
import '/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl(this._remote);

  final ProfileRemoteDataSource _remote;

  @override
  Future<Either<Failure, PlayerEntity>> getProfile(String uid) async {
    try {
      final model = await _remote.getProfile(uid);
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on Exception catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateProfile({
    required String uid,
    String? displayName,
    String? avatarUrl,
  }) async {
    try {
      await _remote.updateProfile(
        uid: uid,
        displayName: displayName,
        avatarUrl: avatarUrl,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on Exception catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
