// Pacage imports:
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Core imports:
import '/core/localization/localization_helpers.dart';
import '/core/widgets/navigation/bottom_navigation_bar.dart';

// Feature imports:
import '/features/home/presentation/screens/home_screen.dart';
import '/features/main/presentation/bloc/navigation_cubit.dart';
import '/features/profile/presentation/screenss/profile_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  List<NavBarItem> _buildNavItems(BuildContext context) {
    return [
      NavBarItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
        label: context.l10n.home,
      ),
      NavBarItem(
        icon: Icons.emoji_events_outlined,
        activeIcon: Icons.emoji_events,
        label: context.l10n.ranks,
      ),
      NavBarItem(
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        label: context.l10n.profile,
      ),
    ];
  }

  static const List<Widget> _pages = [
    HomeScreen(),
    Scaffold(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NavigationCubit(),
      child: BlocBuilder<NavigationCubit, NavigationState>(
        builder: (context, state) {
          return Scaffold(
            extendBody: true,
            body: IndexedStack(index: state.selectedIndex, children: _pages),
            bottomNavigationBar: CustomNavigationBar(
              selectedIndex: state.selectedIndex,
              items: _buildNavItems(context),
              onItemSelected: context.read<NavigationCubit>().changeTab,
            ),
          );
        },
      ),
    );
  }
}
