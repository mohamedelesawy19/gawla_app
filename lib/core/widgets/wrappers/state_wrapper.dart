// Package imports:
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Core imports:
import '/core/di/service_locator.dart';
import '/core/session/bloc/session_bloc.dart';

class StateWrapper extends StatelessWidget {
  const StateWrapper({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: ServiceLocator.get<SessionBloc>(),
      child: child,
    );
  }
}
