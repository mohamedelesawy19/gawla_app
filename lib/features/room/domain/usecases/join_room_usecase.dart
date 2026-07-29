// Package imports:
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

// Core imports:
import '/core/errors/failures.dart';
import '/core/usecases/usecase.dart';

// Features imports:
import '/features/room/domain/entities/room_entity.dart';
import '/features/room/domain/repositories/room_repository.dart';
import '/features/room/domain/validators/join_room_validator.dart';

/// Joins a specific, already-known room (e.g. selected from a public
/// room browser, or a deep link) — as opposed to [QuickMatchUseCase],
/// which finds one automatically.
class JoinRoomUseCase implements UseCase<RoomEntity, JoinRoomParams> {
  const JoinRoomUseCase({required this._repository, required this._validator});

  final RoomRepository _repository;
  final JoinRoomValidator _validator;

  @override
  Future<Either<Failure, RoomEntity>> call(JoinRoomParams params) {
    final errors = _validator.validate(params);

    if (errors.isNotEmpty) {
      return Future.value(Left(ValidationFailure(errors: errors)));
    }

    return _repository.joinRoom(
      roomId: params.roomId,
      uid: params.uid,
      displayName: params.displayName,
      avatarUrl: params.avatarUrl,
    );
  }
}

class JoinRoomParams extends Equatable {
  const JoinRoomParams({
    required this.roomId,
    required this.uid,
    required this.displayName,
    this.avatarUrl,
  });

  final String roomId;
  final String uid;
  final String displayName;
  final String? avatarUrl;

  @override
  List<Object?> get props => [roomId, uid, displayName, avatarUrl];
}
