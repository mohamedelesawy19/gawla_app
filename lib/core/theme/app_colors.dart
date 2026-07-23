import 'package:flutter/material.dart';

abstract final class AppColors {
  // ── Brand ────────────────────────────────────────────────────────────────

  /// Primary: Neon Magenta — Action & Challenges Color
  static const primary = Color(0xFFFF2E7A);
  static const onPrimary = Color(0xFF2B0012);
  static const primaryContainer = Color(0xFF7A0033);
  static const onPrimaryContainer = Color(0xFFFFD6E4);

  /// Secondary: Electric Gold — Win & Trophy Color
  static const secondary = Color(0xFFFFC700);
  static const onSecondary = Color(0xFF2B2000);
  static const secondaryContainer = Color(0xFF5C4700);
  static const onSecondaryContainer = Color(0xFFFFF3C4);

  /// Tertiary: Neon Purple — Special Powers & Highlight Color
  static const tertiary = Color(0xFF9D4EFF);
  static const onTertiary = Color(0xFF1F0033);
  static const tertiaryContainer = Color(0xFF4A1B7A);
  static const onTertiaryContainer = Color(0xFFEBD9FF);

  // ── Neutral ───────────────────────────────────────────────────────────────
  // Dark purple-blue background — gives a "game studio/theater" feel, not a desktop app

  static const background = Color(0xFF0D0818);
  static const onBackground = Color(0xFFF6F1FF);

  static const surface = Color(0xFF0D0818);
  static const onSurface = Color(0xFFF6F1FF);

  static const surfaceVariant = Color(0xFF201530);
  static const onSurfaceVariant = Color(0xFFCBBEDD);

  static const outline = Color(0xFF6B5A85);
  static const outlineVariant = Color(0xFF352548);

  // ── Semantic ──────────────────────────────────────────────────────────────

  /// Red Fire — For Elimination / Loss
  static const error = Color(0xFFFF3B3B);
  static const onError = Color(0xFFFFFFFF);
  static const errorContainer = Color(0xFF5C0A0A);
  static const onErrorContainer = Color(0xFFFFD9D9);

  /// Green Neon — For Win / Advancement to Next Round
  static const success = Color(0xFF00FF85);
  static const onSuccess = Color(0xFF002B14);
  static const successContainer = Color(0xFF0A5C2E);
  static const onSuccessContainer = Color(0xFFC8FFDF);

  /// Orange Electric — For Alerts / Countdown
  static const warning = Color(0xFFFF9500);
  static const onWarning = Color(0xFF2B1600);
  static const warningContainer = Color(0xFF663900);
  static const onWarningContainer = Color(0xFFFFE3C0);
}
