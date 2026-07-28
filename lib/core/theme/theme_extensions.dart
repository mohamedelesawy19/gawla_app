// Package imports:
import 'package:flutter/material.dart';

extension ThemeContextExtensions on BuildContext {
  /// Gets the current theme
  ThemeData get theme => Theme.of(this);

  /// Gets the current color scheme
  ColorScheme get colorScheme => theme.colorScheme;

  /// Gets the current text theme
  TextTheme get textTheme => theme.textTheme;

  /// Check if dark mode
  bool get isDarkMode => colorScheme.brightness == Brightness.dark;

  /// Check if light mode
  bool get isLightMode => !isDarkMode;
}
