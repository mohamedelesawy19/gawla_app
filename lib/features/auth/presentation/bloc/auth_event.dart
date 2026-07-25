part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

final class SignInWithGoogleEvent extends AuthEvent {
  const SignInWithGoogleEvent();
}

final class SignInAnonymouslyEvent extends AuthEvent {
  const SignInAnonymouslyEvent();
}

final class SignOutEvent extends AuthEvent {
  const SignOutEvent();
}
