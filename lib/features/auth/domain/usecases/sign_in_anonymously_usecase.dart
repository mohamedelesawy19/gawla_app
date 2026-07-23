// Package imports:
import 'package:dartz/dartz.dart';

// Core imports:
import '/core/errors/failures.dart';
import '/core/usecases/usecase.dart';

// Features imports:
import '/features/auth/domain/entities/auth_user_entity.dart';
import '/features/auth/domain/repositories/auth_repository.dart';

class SignInAnonymouslyUseCase implements NoParamsUseCase<AuthUserEntity> {
  const SignInAnonymouslyUseCase(this._repository);
  final AuthRepository _repository;

  @override
  Future<Either<Failure, AuthUserEntity>> call() =>
      _repository.signInAnonymously();
}
