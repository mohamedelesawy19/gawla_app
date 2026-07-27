// Package imports:
import 'package:dartz/dartz.dart';

// Core imports:
import '/core/errors/failures.dart';
import '/core/usecases/usecase.dart';

// Feature imports:
import '/features/home/domain/entities/home_dashboard_entity.dart';
import '/features/home/domain/repositories/home_repository.dart';

class GetHomeDashboardUsecase implements NoParamsUseCase<HomeDashboardEntity> {
  const GetHomeDashboardUsecase(this._repository);

  final HomeRepository _repository;

  @override
  Future<Either<Failure, HomeDashboardEntity>> call() {
    return _repository.getHomeDashboard();
  }
}
