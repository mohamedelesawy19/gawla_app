// Package imports:
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Core imports:
import '/core/errors/failures.dart';
import '/core/usecases/usecase.dart';

// Features imports:
import '/features/room/domain/entities/room_entity.dart';
import '/features/room/domain/entities/room_enums.dart';
import '/features/room/domain/entities/room_settings_entity.dart';
import '/features/room/domain/usecases/create_room_usecase.dart';
import '/features/room/domain/usecases/join_room_by_code_usecase.dart';
import '/features/room/domain/usecases/join_room_usecase.dart';
import '/features/room/domain/usecases/kick_player_usecase.dart';
import '/features/room/domain/usecases/leave_room_usecase.dart';
import '/features/room/domain/usecases/quick_join_usecase.dart';
import '/features/room/domain/usecases/update_room_settings_usecase.dart';
import '/features/room/domain/usecases/watch_room_usecase.dart';

// Part imports:
part 'room_event.dart';
part 'room_state.dart';

/// Coordinates the Room feature's use cases and exposes a single stream
/// of [RoomState] for the presentation layer.
///
/// Ownership boundary: this bloc renders and drives a room *once its id
/// is known* — right after a successful create/join/quick-join, or on
/// rehydration once the app shell tells it to via [RoomWatchEvent].
/// Deciding *whether* the current user belongs to a room at all is
/// `SessionBloc`'s job (via `WatchRoomIdForUserUseCase`), not this
/// bloc's, so that use case is intentionally not wired in here.
class RoomBloc extends Bloc<RoomEvent, RoomState> {
  RoomBloc({
    required this._createRoom,
    required this._joinRoom,
    required this._joinRoomByCode,
    required this._quickJoin,
    required this._leaveRoom,
    required this._kickPlayer,
    required this._updateRoomSettings,
    required this._watchRoom,
  }) : super(const RoomState()) {
    on<RoomCreateEvent>(_onCreate, transformer: droppable());
    on<RoomJoinEvent>(_onJoin, transformer: droppable());
    on<RoomJoinByCodeEvent>(_onJoinByCode, transformer: droppable());
    on<RoomQuickJoinEvent>(_onQuickJoin, transformer: droppable());
    on<RoomLeaveEvent>(_onLeave, transformer: droppable());
    // Sequential, not droppable: a host kicking several players in quick
    // succession expects every kick to go through, not just the first.
    on<RoomKickPlayerEvent>(_onKickPlayer, transformer: sequential());
    on<RoomUpdateSettingsEvent>(_onUpdateSettings, transformer: droppable());
    // Restartable: a new watch request (including a "stop", i.e. `null`
    // roomId) must always supersede whatever was previously being
    // streamed, so the old subscription is cancelled cleanly.
    on<RoomWatchEvent>(_onWatch, transformer: restartable());
  }

  final CreateRoomUseCase _createRoom;
  final JoinRoomUseCase _joinRoom;
  final JoinRoomByCodeUseCase _joinRoomByCode;
  final QuickJoinUseCase _quickJoin;
  final LeaveRoomUseCase _leaveRoom;
  final KickPlayerUseCase _kickPlayer;
  final UpdateRoomSettingsUseCase _updateRoomSettings;
  final WatchRoomUseCase _watchRoom;

  Future<void> _onCreate(RoomCreateEvent event, Emitter<RoomState> emit) async {
    emit(state.copyWith(status: RoomBlocStatus.loading, clearFailure: true));

    final result = await _createRoom(
      CreateRoomParams(visibility: event.visibility, settings: event.settings),
    );

    _emitRoomResult(result, emit);
  }

  Future<void> _onJoin(RoomJoinEvent event, Emitter<RoomState> emit) async {
    emit(state.copyWith(status: RoomBlocStatus.loading, clearFailure: true));

    final result = await _joinRoom(JoinRoomParams(roomId: event.roomId));

    _emitRoomResult(result, emit);
  }

  Future<void> _onJoinByCode(
    RoomJoinByCodeEvent event,
    Emitter<RoomState> emit,
  ) async {
    emit(state.copyWith(status: RoomBlocStatus.loading, clearFailure: true));

    final result = await _joinRoomByCode(
      JoinRoomByCodeParams(inviteCode: event.inviteCode),
    );

    _emitRoomResult(result, emit);
  }

  Future<void> _onQuickJoin(
    RoomQuickJoinEvent event,
    Emitter<RoomState> emit,
  ) async {
    emit(state.copyWith(status: RoomBlocStatus.loading, clearFailure: true));

    final defaultSettings = event.defaultSettings;
    final result = await (defaultSettings == null
        ? _quickJoin(const QuickJoinParams())
        : _quickJoin(QuickJoinParams(defaultSettings: defaultSettings)));

    _emitRoomResult(result, emit);
  }

  Future<void> _onLeave(RoomLeaveEvent event, Emitter<RoomState> emit) async {
    final roomId = state.room?.roomId;
    if (roomId == null) return;

    emit(state.copyWith(isPerformingAction: true, clearFailure: true));

    final result = await _leaveRoom(LeaveRoomParams(roomId: roomId));

    result.fold(
      (failure) =>
          emit(state.copyWith(isPerformingAction: false, failure: failure)),
      // Having left, we no longer care about this room's updates.
      (_) => add(const RoomWatchEvent()),
    );
  }

  Future<void> _onKickPlayer(
    RoomKickPlayerEvent event,
    Emitter<RoomState> emit,
  ) async {
    final roomId = state.room?.roomId;
    if (roomId == null) return;

    emit(state.copyWith(isPerformingAction: true, clearFailure: true));

    final result = await _kickPlayer(
      KickPlayerParams(roomId: roomId, targetUid: event.targetUid),
    );

    // No need to touch `room` here: the ongoing watch subscription will
    // deliver the updated player list on its own.
    emit(
      result.fold(
        (failure) =>
            state.copyWith(isPerformingAction: false, failure: failure),
        (_) => state.copyWith(isPerformingAction: false),
      ),
    );
  }

  Future<void> _onUpdateSettings(
    RoomUpdateSettingsEvent event,
    Emitter<RoomState> emit,
  ) async {
    final roomId = state.room?.roomId;
    if (roomId == null) return;

    emit(state.copyWith(isPerformingAction: true, clearFailure: true));

    final result = await _updateRoomSettings(
      UpdateRoomSettingsParams(roomId: roomId, settings: event.settings),
    );

    emit(
      result.fold(
        (failure) =>
            state.copyWith(isPerformingAction: false, failure: failure),
        (_) => state.copyWith(isPerformingAction: false),
      ),
    );
  }

  Future<void> _onWatch(RoomWatchEvent event, Emitter<RoomState> emit) async {
    final roomId = event.roomId;
    if (roomId == null) {
      emit(const RoomState());
      return;
    }

    await emit.forEach<RoomEntity?>(
      _watchRoom(SingleParam(roomId)),
      onData: (room) => room == null
          // Room was closed (e.g. the last player left) — nothing left
          // to watch.
          ? const RoomState()
          : state.copyWith(
              status: RoomBlocStatus.inRoom,
              room: room,
              isPerformingAction: false,
              clearFailure: true,
            ),
      onError: (error, stackTrace) => state.copyWith(
        status: RoomBlocStatus.failure,
        failure: ServerFailure(message: error.toString()),
      ),
    );
  }

  /// Shared by every one-shot action that produces a [RoomEntity]
  /// (create, join, join-by-code, quick join): moves into the room and
  /// kicks off realtime watching for it.
  void _emitRoomResult(
    Either<Failure, RoomEntity> result,
    Emitter<RoomState> emit,
  ) {
    result.fold(
      (failure) => emit(
        state.copyWith(status: RoomBlocStatus.failure, failure: failure),
      ),
      (room) {
        emit(
          state.copyWith(
            status: RoomBlocStatus.inRoom,
            room: room,
            clearFailure: true,
          ),
        );
        add(RoomWatchEvent(roomId: room.roomId));
      },
    );
  }
}
