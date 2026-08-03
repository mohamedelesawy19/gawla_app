// Package imports:
import 'package:go_router/go_router.dart';

// Core imports:
import '/core/router/app_routes.dart';

// Feature imports:
import '/features/room/presentation/screens/create_room_screen.dart';
import '/features/room/presentation/screens/join_room_screen.dart';
import '/features/room/presentation/screens/room_screen.dart';

class RoomRoutes {
  const RoomRoutes._();

  static List<GoRoute> get routes => [
    GoRoute(
      path: AppRoutes.createRoom,
      builder: (context, state) => const CreateRoomScreen(),
    ),
    GoRoute(
      path: AppRoutes.joinRoom,
      builder: (context, state) => const JoinRoomScreen(),
    ),
    GoRoute(
      path: '${AppRoutes.room}/:roomId',
      builder: (context, state) =>
          RoomScreen(roomId: state.pathParameters['roomId']!),
    ),
  ];
}
