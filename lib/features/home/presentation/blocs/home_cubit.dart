// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Core imports:
import '/core/errors/failures.dart';

// Feature imports:
import '/features/home/domain/entities/home_dashboard_entity.dart';
import '/features/home/domain/entities/mini_game_preview_entity.dart';
import '/features/home/domain/usecases/get_home_dashboard_usecase.dart';

// Part imports:
part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({required this._getHomeDashboard}) : super(const HomeState()) {
    _load();
  }

  final GetHomeDashboardUsecase _getHomeDashboard;

  Future<void> _load() async {
    emit(state.copyWith(status: HomeStatus.loading));

    final result = await _getHomeDashboard();

    result.fold(
      (failure) =>
          emit(state.copyWith(status: HomeStatus.error, failure: failure)),
      (dashboard) => emit(_loadedStateFrom(dashboard)),
    );
  }

  HomeState _loadedStateFrom(HomeDashboardEntity dashboard) {
    return state.copyWith(
      status: HomeStatus.loaded,
      tournamentPlayerCount: dashboard.tournamentPlayerCount,
      tournamentRoundCount: dashboard.tournamentRoundCount,
      todaysRotation: dashboard.todaysRotation,
      gameLibrary: dashboard.gameLibrary,
    );
  }

  Future<void> refresh() => _load();
}
