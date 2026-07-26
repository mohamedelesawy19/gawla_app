// Package imports:
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

// Core imports:
import '/core/errors/failures.dart';
import '/core/usecases/usecase.dart';

// Feature imports:
import '/features/profile/domain/repositories/profile_repository.dart';

class UpdateProfileUseCase implements UseCase<void, UpdateProfileParams> {
  const UpdateProfileUseCase(this._repository);
  final ProfileRepository _repository;

  @override
  Future<Either<Failure, void>> call(UpdateProfileParams params) {
    final displayName = params.displayName?.trim();

    if (displayName == null && params.avatarUrl == null) {
      return Future.value(
        const Left(ValidationFailure(message: 'Nothing to update')),
      );
    }

    if (displayName != null && displayName.isEmpty) {
      return Future.value(
        const Left(ValidationFailure(message: 'Display name cannot be empty')),
      );
    }

    return _repository.updateProfile(
      uid: params.uid,
      displayName: displayName,
      avatarUrl: params.avatarUrl,
    );
  }
}

class UpdateProfileParams extends Equatable {
  const UpdateProfileParams({
    required this.uid,
    this.displayName,
    this.avatarUrl,
  });

  final String uid;

  /// `null` = "leave unchanged". This lets the bloc send only the fields
  /// the user actually edited instead of resubmitting the whole profile.
  final String? displayName;
  final String? avatarUrl;

  @override
  List<Object?> get props => [uid, displayName, avatarUrl];
}
