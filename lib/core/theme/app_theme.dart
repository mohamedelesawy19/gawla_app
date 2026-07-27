// Package imports:
import 'package:flutter/material.dart';

// Core imports:
import '/core/widgets/design_system/colors.dart';
import '/core/widgets/design_system/typography.dart';

abstract final class AppTheme {
  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: AppTypography.bodyFontFamily,
    fontFamilyFallback: const [AppTypography.headingFontFamily],
    textTheme: AppTypography.defaultTextTheme,
    colorScheme: AppColors.colorScheme,
    appBarTheme: const AppBarTheme(centerTitle: true),
    splashFactory: InkRipple.splashFactory,
  );
}
