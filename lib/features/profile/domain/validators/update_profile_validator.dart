// Core imports:
import '/core/validator/validator.dart';

// Features imports:
import '/features/profile/domain/usecases/update_profile_usecase.dart';
import '/features/profile/domain/validators/profile_validation_error.dart';

class UpdateProfileValidator
    implements Validator<UpdateProfileParams, ProfileValidationError> {
  const UpdateProfileValidator();

  @override
  List<ProfileValidationError> validate(UpdateProfileParams params) {
    final errors = <ProfileValidationError>[];

    final displayName = params.displayName?.trim();

    if (displayName == null && params.avatarUrl == null) {
      errors.add(ProfileValidationError.nothingToUpdate);
    }

    if (displayName != null && displayName.isEmpty) {
      errors.add(ProfileValidationError.emptyDisplayName);
    }

    return errors;
  }
}
