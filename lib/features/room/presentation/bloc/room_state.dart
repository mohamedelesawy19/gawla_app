part of 'room_bloc.dart';

enum RoomBlocStatus { initial, loading, inRoom, failure }

class RoomState extends Equatable {
  const RoomState({
    this.status = RoomBlocStatus.initial,
    this.room,
    this.failure,
    this.isPerformingAction = false,
  });

  final RoomBlocStatus status;

  /// The room currently being watched. Present once [status] is
  /// [RoomBlocStatus.inRoom]; `null` otherwise.
  final RoomEntity? room;

  final Failure? failure;

  /// True while a secondary action — leave, kick, or a settings update —
  /// is in flight on top of an already-loaded room, so the UI can show
  /// an inline spinner without dropping the current room view.
  final bool isPerformingAction;

  bool get isLoading => status == RoomBlocStatus.loading;

  bool get isInRoom => status == RoomBlocStatus.inRoom && room != null;

  bool get hasFailure => failure != null;

  RoomState copyWith({
    RoomBlocStatus? status,
    RoomEntity? room,
    Failure? failure,
    bool? isPerformingAction,
    bool clearFailure = false,
  }) {
    return RoomState(
      status: status ?? this.status,
      room: room ?? this.room,
      failure: clearFailure ? null : (failure ?? this.failure),
      isPerformingAction: isPerformingAction ?? this.isPerformingAction,
    );
  }

  @override
  List<Object?> get props => [status, room, failure, isPerformingAction];
}
