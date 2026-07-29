// Package imports:
import 'package:equatable/equatable.dart';

// Core imports:
import '/core/validator/validator.dart';

abstract class Failure extends Equatable {
  const Failure({required this.message, this.code});

  final String message;
  final String? code;

  @override
  List<Object?> get props => [message, code];
}

class AuthFailure extends Failure {
  const AuthFailure({required super.message, super.code});
}

class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.code});
}

class ParsingFailure extends Failure {
  const ParsingFailure({required super.message, super.code});
}

class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'No internet connection.', super.code});
}

class ValidationFailure extends Failure {
  const ValidationFailure({required this.errors})
    : super(message: 'validation_failed');

  final List<ValidationError> errors;

  @override
  List<Object?> get props => [errors];
}

class UnknownFailure extends Failure {
  const UnknownFailure({
    super.message = 'An unexpected error occurred.',
    super.code,
  });
}
