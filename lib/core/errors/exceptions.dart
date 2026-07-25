import 'package:equatable/equatable.dart';

abstract class BaseException extends Equatable implements Exception {
  const BaseException({required this.message, this.code});

  final String message;
  final String? code;

  @override
  List<Object?> get props => [message, code];
}

class ServerException extends BaseException {
  const ServerException({required super.message, super.code});
}

class AuthException extends BaseException {
  const AuthException({required super.message, super.code});
}

class ParsingException extends BaseException {
  const ParsingException({required super.message, super.code});
}

class NetworkException extends BaseException {
  const NetworkException({required super.message, super.code});
}
