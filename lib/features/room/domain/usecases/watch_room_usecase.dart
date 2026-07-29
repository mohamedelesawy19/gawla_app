// Core imports:
import '/core/usecases/usecase.dart';

// Features imports:
import '/features/room/domain/entities/room_entity.dart';
import '/features/room/domain/repositories/room_repository.dart';

/// Streams live updates for a single room. Used by `RoomBloc` to render
/// the waiting room once a `roomId` is known (after create/join, or on
/// rehydration when `SessionBloc` already reports `inRoom`).
class WatchRoomUseCase
    implements StreamUseCase<RoomEntity?, SingleParam<String>> {
  const WatchRoomUseCase(this._repository);

  final RoomRepository _repository;

  @override
  Stream<RoomEntity?> call(SingleParam<String> params) =>
      _repository.watchRoom(params.value);
}
