part of 'home_cubit.dart';

enum HomeStatus { initial, loading, loaded, error }

class HomeState extends Equatable {
  const HomeState({
    this.status = HomeStatus.initial,
    this.tournamentPlayerCount = 0,
    this.tournamentRoundCount = 0,
    this.todaysRotation = const [],
    this.gameLibrary = const [],
    this.failure,
  });

  final HomeStatus status;
  final int tournamentPlayerCount;
  final int tournamentRoundCount;
  final List<MiniGamePreviewEntity> todaysRotation;
  final List<MiniGamePreviewEntity> gameLibrary;
  final Failure? failure;

  HomeState copyWith({
    HomeStatus? status,
    int? tournamentPlayerCount,
    int? tournamentRoundCount,
    List<MiniGamePreviewEntity>? todaysRotation,
    List<MiniGamePreviewEntity>? gameLibrary,
    Failure? failure,
  }) {
    return HomeState(
      status: status ?? this.status,
      tournamentPlayerCount:
          tournamentPlayerCount ?? this.tournamentPlayerCount,
      tournamentRoundCount: tournamentRoundCount ?? this.tournamentRoundCount,
      todaysRotation: todaysRotation ?? this.todaysRotation,
      gameLibrary: gameLibrary ?? this.gameLibrary,
      failure: failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props => [
    status,
    tournamentPlayerCount,
    tournamentRoundCount,
    todaysRotation,
    gameLibrary,
    failure,
  ];
}
