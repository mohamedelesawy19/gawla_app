// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Part imports:
part 'navigation_state.dart';

class NavigationCubit extends Cubit<NavigationState> {
  NavigationCubit() : super(const NavigationState(selectedIndex: 0));

  void changeTab(int index) {
    if (state.selectedIndex == index) return;

    emit(state.copyWith(selectedIndex: index));
  }

  void goHome() => changeTab(0);

  void goRanks() => changeTab(1);

  void goProfile() => changeTab(2);
}
