// Package imports:
import 'package:dartz/dartz.dart';

// Core imports:
import '/core/errors/failures.dart';

// Feature imports:
import '/features/home/domain/entities/home_dashboard_entity.dart';

abstract class HomeRepository {
  Future<Either<Failure, HomeDashboardEntity>> getHomeDashboard();
}
