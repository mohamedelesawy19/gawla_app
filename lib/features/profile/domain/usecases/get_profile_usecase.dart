// Package imports:
import 'package:dartz/dartz.dart';

// Core imports:
import '/core/errors/failures.dart';
import '/core/usecases/usecase.dart';

// Feature imports:
import '/features/profile/domain/entities/player_entity.dart';
import '/features/profile/domain/repositories/profile_repository.dart';

class GetProfileUseCase implements UseCase<PlayerEntity, SingleParam<String>> {
  const GetProfileUseCase(this._repository);
  final ProfileRepository _repository;

  @override
  Future<Either<Failure, PlayerEntity>> call(SingleParam<String> params) {
    return _repository.getProfile(params.value);
  }
}
