part of 'navigation_cubit.dart';

final class NavigationState extends Equatable {
  const NavigationState({required this.selectedIndex});

  final int selectedIndex;

  NavigationState copyWith({int? selectedIndex}) {
    return NavigationState(selectedIndex: selectedIndex ?? this.selectedIndex);
  }

  @override
  List<Object> get props => [selectedIndex];
}
