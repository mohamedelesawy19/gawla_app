// Package imports:
import 'package:flutter/material.dart';

// Core imports:
import '/core/design_system/colors.dart';

abstract final class AppTypography {
  const AppTypography._();

  // ── FONT FAMILIES ──────────────────────────────────────────────────────────

  /// For headings, display text, and buttons — energy and fun
  static const String headingFontFamily = 'BalooBhaijaan2';

  /// For body text, labels, and data — clarity in reading
  static const String bodyFontFamily = 'Cairo';

  static const String monoFontFamily = 'RobotoMono';

  // ── COLORS ─────────────────────────────────────────────────────────────────
  static const primary = AppColors.textPrimary;
  static const secondary = AppColors.textSecondary;

  // ── FONT WEIGHTS ───────────────────────────────────────────────────────────

  static const FontWeight thin = FontWeight.w100;
  static const FontWeight extraLight = FontWeight.w200;
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extraBold = FontWeight.w800;
  static const FontWeight black = FontWeight.w900;

  // ── DISPLAY STYLES (Baloo) ────────────────────────────────────────────────

  static const TextStyle displayLarge = TextStyle(
    fontFamily: headingFontFamily,
    fontSize: 57,
    fontWeight: regular,
    height: 1.12,
    letterSpacing: -0.25,
    color: primary,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: headingFontFamily,
    fontSize: 45,
    fontWeight: regular,
    height: 1.16,
    letterSpacing: 0,
    color: primary,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: headingFontFamily,
    fontSize: 36,
    fontWeight: regular,
    height: 1.22,
    letterSpacing: 0,
    color: primary,
  );

  // ── HEADLINE STYLES (Baloo) ────────────────────────────────────────────────

  static const TextStyle headlineLarge = TextStyle(
    fontFamily: headingFontFamily,
    fontSize: 32,
    fontWeight: regular,
    height: 1.25,
    letterSpacing: 0,
    color: primary,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: headingFontFamily,
    fontSize: 28,
    fontWeight: regular,
    height: 1.29,
    letterSpacing: 0,
    color: primary,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: headingFontFamily,
    fontSize: 24,
    fontWeight: regular,
    height: 1.33,
    letterSpacing: 0,
    color: primary,
  );

  // ── TITLE STYLES (Baloo) ───────────────────────────────────────────────────

  static const TextStyle titleLarge = TextStyle(
    fontFamily: headingFontFamily,
    fontSize: 22,
    fontWeight: regular,
    height: 1.27,
    letterSpacing: 0,
    color: primary,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: headingFontFamily,
    fontSize: 16,
    fontWeight: medium,
    height: 1.50,
    letterSpacing: 0.15,
    color: primary,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: headingFontFamily,
    fontSize: 14,
    fontWeight: medium,
    height: 1.43,
    letterSpacing: 0.10,
    color: primary,
  );

  // ── LABEL STYLES (Cairo) ───────────────────────────────────────────────────

  static const TextStyle labelLarge = TextStyle(
    fontFamily: bodyFontFamily,
    fontSize: 14,
    fontWeight: medium,
    height: 1.43,
    letterSpacing: 0.10,
    color: primary,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: bodyFontFamily,
    fontSize: 12,
    fontWeight: medium,
    height: 1.33,
    letterSpacing: 0.50,
    color: secondary,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: bodyFontFamily,
    fontSize: 11,
    fontWeight: medium,
    height: 1.45,
    letterSpacing: 0.50,
    color: secondary,
  );

  // ── BODY STYLES (Cairo) ────────────────────────────────────────────────────

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: bodyFontFamily,
    fontSize: 16,
    fontWeight: regular,
    height: 1.50,
    letterSpacing: 0.50,
    color: primary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: bodyFontFamily,
    fontSize: 14,
    fontWeight: regular,
    height: 1.43,
    letterSpacing: 0.25,
    color: primary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: bodyFontFamily,
    fontSize: 12,
    fontWeight: regular,
    height: 1.33,
    letterSpacing: 0.40,
    color: secondary,
  );

  // ── SPECIALIZED STYLES ─────────────────────────────────────────────────────

  /// Code style for inline code snippets
  static const TextStyle code = TextStyle(
    fontFamily: monoFontFamily,
    fontSize: 14,
    fontWeight: regular,
    height: 1.43,
    letterSpacing: 0.25,
    color: primary,
  );

  /// Caption style for image captions and metadata
  static const TextStyle caption = TextStyle(
    fontFamily: bodyFontFamily,
    fontSize: 12,
    fontWeight: regular,
    height: 1.33,
    letterSpacing: 0.40,
    color: secondary,
  );

  /// Overline style for category labels and tags
  static const TextStyle overline = TextStyle(
    fontFamily: bodyFontFamily,
    fontSize: 10,
    fontWeight: medium,
    height: 1.60,
    letterSpacing: 1.50,
    color: primary,
  );

  // ── BUTTON STYLES (Baloo) ──────────────────────────────────────────────────

  static const TextStyle buttonPrimary = TextStyle(
    fontFamily: headingFontFamily,
    fontSize: 14,
    fontWeight: medium,
    height: 1.43,
    letterSpacing: 0.10,
    color: primary,
  );

  static const TextStyle buttonSecondary = TextStyle(
    fontFamily: headingFontFamily,
    fontSize: 14,
    fontWeight: medium,
    height: 1.43,
    letterSpacing: 0.10,
    color: secondary,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontFamily: headingFontFamily,
    fontSize: 12,
    fontWeight: medium,
    height: 1.33,
    letterSpacing: 0.50,
    color: primary,
  );
}
