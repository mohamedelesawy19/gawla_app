// Package imports:
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Core imports:
import '/core/errors/failures.dart';
import '/core/usecases/usecase.dart';

// Feature imports:
import '/features/profile/domain/entities/player_entity.dart';
import '/features/profile/domain/usecases/get_profile_usecase.dart';
import '/features/profile/domain/usecases/update_profile_usecase.dart';

// Part imports:
part 'profile_event.dart';
part 'profile_state.dart';

/// Manages a single player's profile screen: fetch + edit.
///
/// Deliberately independent of `SessionBloc` — just like `AuthBloc` doesn't
/// know about profile data, this bloc only knows about the `uid` it's given
/// in each event. `SessionBloc` (or whatever page hosts this bloc) is
/// responsible for supplying the current `uid`.
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc({required this._getProfile, required this._updateProfile})
    : super(const ProfileInitial()) {
    on<GetProfileEvent>(_onGetProfile, transformer: restartable());
    on<UpdateProfileEvent>(_onUpdateProfile, transformer: droppable());
  }

  final GetProfileUseCase _getProfile;
  final UpdateProfileUseCase _updateProfile;

  // ── Handlers ───────────────────────────────────────────────────────────────

  Future<void> _onGetProfile(
    GetProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    final result = await _getProfile(SingleParam(event.uid));
    result.fold(
      (failure) => emit(ProfileError(failure: failure)),
      (profile) => emit(ProfileLoaded(profile: profile)),
    );
  }

  Future<void> _onUpdateProfile(
    UpdateProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    final current = _currentProfile;
    emit(ProfileUpdating(profile: current));

    final result = await _updateProfile(
      UpdateProfileParams(
        uid: event.uid,
        displayName: event.displayName,
        avatarUrl: event.avatarUrl,
      ),
    );

    result.fold(
      (failure) => emit(ProfileError(failure: failure, profile: current)),
      (_) {
        if (current != null) {
          emit(
            ProfileLoaded(
              profile: current.copyWith(
                displayName: event.displayName?.trim(),
                avatarUrl: event.avatarUrl,
              ),
            ),
          );
        } else {
          add(GetProfileEvent(uid: event.uid));
        }
      },
    );
  }

  /// The last known profile under whatever the current state is — used so
  /// an in-flight update doesn't blank the screen.
  PlayerEntity? get _currentProfile {
    final s = state;
    if (s is ProfileLoaded) return s.profile;
    if (s is ProfileUpdating) return s.profile;
    if (s is ProfileError) return s.profile;
    return null;
  }
}
