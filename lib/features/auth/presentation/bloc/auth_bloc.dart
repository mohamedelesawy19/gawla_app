// Package imports:
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Core imports:
import '/core/errors/failures.dart';

// Feature imports:
import '/features/auth/domain/usecases/sign_in_anonymously_usecase.dart';
import '/features/auth/domain/usecases/sign_in_with_google_usecase.dart';
import '/features/auth/domain/usecases/sign_out_usecase.dart';

// Part imports:
part 'auth_event.dart';
part 'auth_state.dart';

/// Handles authentication operations only.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required this._signInWithGoogle,
    required this._signInAnonymously,
    required this._signOut,
  }) : super(const AuthInitial()) {
    on<SignInWithGoogleEvent>(_onSignInWithGoogle, transformer: droppable());
    on<SignInAnonymouslyEvent>(_onSignInAnonymously, transformer: droppable());
    on<SignOutEvent>(_onSignOut, transformer: droppable());
  }

  final SignInWithGoogleUseCase _signInWithGoogle;
  final SignInAnonymouslyUseCase _signInAnonymously;
  final SignOutUseCase _signOut;

  // ── Handlers ───────────────────────────────────────────────────────────────

  Future<void> _onSignInWithGoogle(
    SignInWithGoogleEvent _,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _signInWithGoogle();
    result.fold(
      (failure) => emit(AuthFailure(failure: failure)),
      (_) => emit(const AuthSuccess()),
      // Note: There is no emit for the "Authenticated" state here.
      // The SessionBloc will observe the login success through the stream.
    );
  }

  Future<void> _onSignInAnonymously(
    SignInAnonymouslyEvent _,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _signInAnonymously();
    result.fold(
      (failure) => emit(AuthFailure(failure: failure)),
      (_) => emit(const AuthSuccess()),
    );
  }

  Future<void> _onSignOut(SignOutEvent _, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await _signOut();
    result.fold((failure) => emit(AuthFailure(failure: failure)), (_) {
      emit(const AuthInitial());
    });
  }
}
