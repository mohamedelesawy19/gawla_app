import '/core/validator/validator.dart';

enum ProfileValidationError implements ValidationError {
  nothingToUpdate,
  emptyDisplayName,
}
