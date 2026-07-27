// Package imports:
import 'package:dartz/dartz.dart';

// Core imports:
import '/core/errors/exceptions.dart';
import '/core/errors/failures.dart';

// Feature imports:
import '/features/home/data/datasources/home_remote_data_source.dart';
import '/features/home/domain/entities/home_dashboard_entity.dart';
import '/features/home/domain/repositories/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  const HomeRepositoryImpl(this._remoteDataSource);

  final HomeRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, HomeDashboardEntity>> getHomeDashboard() async {
    try {
      final model = await _remoteDataSource.getHomeDashboard();
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on Exception catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
