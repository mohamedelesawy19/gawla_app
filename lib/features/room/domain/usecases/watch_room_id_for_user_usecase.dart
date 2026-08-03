// Core imports:
import '/core/usecases/usecase.dart';

// Features imports:
import '/features/room/domain/repositories/room_repository.dart';

/// Streams the id of the room a user currently belongs to, or `null`.
class WatchRoomIdForUserUseCase
    implements StreamUseCase<String?, SingleParam<String>> {
  const WatchRoomIdForUserUseCase(this._repository);

  final RoomRepository _repository;

  @override
  Stream<String?> call(SingleParam<String> params) =>
      _repository.watchRoomIdForUser(params.value);
}
