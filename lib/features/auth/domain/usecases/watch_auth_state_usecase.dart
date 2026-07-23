// Core imports:
import '/core/usecases/usecase.dart';

// Features imports:
import '/features/auth/domain/entities/auth_user_entity.dart';
import '/features/auth/domain/repositories/auth_repository.dart';

class WatchAuthStateUseCase implements NoParamsStreamUseCase<AuthUserEntity?> {
  const WatchAuthStateUseCase(this._repository);
  final AuthRepository _repository;

  @override
  Stream<AuthUserEntity?> call() => _repository.watchAuthState();
}
