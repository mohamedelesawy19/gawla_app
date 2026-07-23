// Package imports:
import 'package:flutter/material.dart';

// Core imports:
import '/core/widgets/feedback/loading_indicator.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: LoadingIndicator()));
  }
}
