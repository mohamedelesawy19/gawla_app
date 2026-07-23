import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTextTheme {
  static const textTheme = TextTheme(
    // ── Display ──────────────────────────────────────────────────────────
    displayLarge: TextStyle(
      fontSize: 57,
      fontWeight: FontWeight.w800,
      letterSpacing: -1,
      color: AppColors.onSurface,
    ),
    displayMedium: TextStyle(
      fontSize: 45,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.5,
      color: AppColors.onSurface,
    ),
    displaySmall: TextStyle(
      fontSize: 36,
      fontWeight: FontWeight.w700,
      color: AppColors.onSurface,
    ),

    // ── Headline ─────────────────────────────────────────────────────────
    headlineLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w800,
      color: AppColors.onSurface,
    ),
    headlineMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      color: AppColors.onSurface,
    ),
    headlineSmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: AppColors.onSurface,
    ),

    // ── Title ─────────────────────────────────────────────────────────────
    titleLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      color: AppColors.onSurface,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.15,
      color: AppColors.onSurface,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
      color: AppColors.onSurface,
    ),

    // ── Body ──────────────────────────────────────────────────────────────
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.5,
      color: AppColors.onSurface,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
      color: AppColors.onSurface,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
      color: AppColors.onSurface,
    ),

    // ── Label ─────────────────────────────────────────────────────────────
    // Label text is used for buttons, captions, and overline text.
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.1,
      color: AppColors.onSurface,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.5,
      color: AppColors.onSurface,
    ),
    labelSmall: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
      color: AppColors.onSurface,
    ),
  );
}
