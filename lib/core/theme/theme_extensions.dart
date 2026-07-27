// Package imports:
import 'package:flutter/material.dart';

// Core imports:
import '/core/design_system/colors.dart';

extension ThemeContextExtensions on BuildContext {
  /// Gets the current theme
  ThemeData get theme => Theme.of(this);

  /// Gets the current color scheme
  ColorScheme get colorScheme => theme.colorScheme;

  /// Gets the current text theme
  TextTheme get textTheme => theme.textTheme;

  /// Semantic colors
  Color get successColor => AppColors.success;
  Color get onSuccessColor => AppColors.onSuccess;
  Color get successContainer => AppColors.successContainer;
  Color get onSuccessContainer => AppColors.onSuccessContainer;
  Color get warningColor => AppColors.warning;
  Color get onWarningColor => AppColors.onWarning;
  Color get warningContainer => AppColors.warningContainer;
  Color get onWarningContainer => AppColors.onWarningContainer;

  /// Check if dark mode
  bool get isDarkMode => colorScheme.brightness == Brightness.dark;

  /// Check if light mode
  bool get isLightMode => !isDarkMode;
}
