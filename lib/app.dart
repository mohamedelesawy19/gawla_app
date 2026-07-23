// Package imports:
import 'package:flutter/material.dart';

// Core imports:
import '/core/localization/localization_delegate.dart';
import '/core/router/app_router.dart';
import '/core/theme/app_theme.dart';

class GawlaApp extends StatelessWidget {
  const GawlaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Gawla',

      // Localization configuration
      localizationsDelegates: LocalizationConfig.localizationsDelegates,
      supportedLocales: LocalizationConfig.supportedLocales,
      locale: LocalizationConfig.getDeviceLocale(),

      // Theme configuration
      theme: AppTheme.theme,

      // Router configuration
      routerConfig: AppRouter.router,
    );
  }
}
