// Package imports:
import 'package:dartz/dartz.dart';

// Core imports:
import '/core/errors/failures.dart';
import '/core/usecases/usecase.dart';

// Features imports:
import '/features/auth/domain/repositories/auth_repository.dart';

class SignOutUseCase implements NoParamsUseCase<void> {
  const SignOutUseCase(this._repository);
  final AuthRepository _repository;

  @override
  Future<Either<Failure, void>> call() => _repository.signOut();
}
