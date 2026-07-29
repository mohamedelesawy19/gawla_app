// Package imports:
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

// Core imports:
import '/core/errors/failures.dart';
import '/core/usecases/usecase.dart';

// Feature imports:
import '/features/profile/domain/repositories/profile_repository.dart';
import '/features/profile/domain/validators/update_profile_validator.dart';

class UpdateProfileUseCase implements UseCase<void, UpdateProfileParams> {
  const UpdateProfileUseCase({
    required this._repository,
    required this._validator,
  });

  final ProfileRepository _repository;
  final UpdateProfileValidator _validator;

  @override
  Future<Either<Failure, void>> call(UpdateProfileParams params) {
    final errors = _validator.validate(params);

    if (errors.isNotEmpty) {
      return Future.value(Left(ValidationFailure(errors: errors)));
    }

    return _repository.updateProfile(
      uid: params.uid,
      displayName: params.displayName?.trim(),
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
