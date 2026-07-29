// Package imports:
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

// Core imports:
import '/core/errors/failures.dart';
import '/core/usecases/usecase.dart';

// Features imports:
import '/features/room/domain/repositories/room_repository.dart';

class LeaveRoomUseCase implements UseCase<void, LeaveRoomParams> {
  const LeaveRoomUseCase(this._repository);

  final RoomRepository _repository;

  @override
  Future<Either<Failure, void>> call(LeaveRoomParams params) {
    return _repository.leaveRoom(roomId: params.roomId, uid: params.uid);
  }
}

class LeaveRoomParams extends Equatable {
  const LeaveRoomParams({required this.roomId, required this.uid});

  final String roomId;
  final String uid;

  @override
  List<Object?> get props => [roomId, uid];
}
