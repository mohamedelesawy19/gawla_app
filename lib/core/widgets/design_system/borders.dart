import 'package:flutter/material.dart';

abstract final class AppBorders {
  const AppBorders._();

  // ── BORDER WIDTHS ──────────────────────────────────────────────────────────

  /// No border
  static const double widthNone = 0.0;

  /// Thin border width
  static const double widthThin = 1.0;

  /// Medium border width
  static const double widthMedium = 2.0;

  /// Thick border width
  static const double widthThick = 4.0;

  /// Extra thick border width
  static const double widthExtraThick = 8.0;

  // ── BORDER RADIUS ──────────────────────────────────────────────────────────

  /// No border radius
  static const double radiusNone = 0.0;

  /// Extra small border radius
  static const double radiusXs = 2.0;

  /// Small border radius
  static const double radiusSm = 4.0;

  /// Medium border radius
  static const double radiusMd = 8.0;

  /// Large border radius
  static const double radiusLg = 12.0;

  /// Extra large border radius
  static const double radiusXl = 16.0;

  /// Double extra large border radius
  static const double radiusXxl = 20.0;

  /// Triple extra large border radius
  static const double radiusXxxl = 24.0;

  /// Full border radius (circular)
  static const double radiusFull = 999.0;

  // ── BORDER RADIUS PRESETS ──────────────────────────────────────────────────

  /// No border radius
  static const BorderRadius borderRadiusNone = BorderRadius.zero;

  /// Extra small border radius
  static const BorderRadius borderRadiusXs = BorderRadius.all(
    Radius.circular(radiusXs),
  );

  /// Small border radius
  static const BorderRadius borderRadiusSm = BorderRadius.all(
    Radius.circular(radiusSm),
  );

  /// Medium border radius
  static const BorderRadius borderRadiusMd = BorderRadius.all(
    Radius.circular(radiusMd),
  );

  /// Large border radius
  static const BorderRadius borderRadiusLg = BorderRadius.all(
    Radius.circular(radiusLg),
  );

  /// Extra large border radius
  static const BorderRadius borderRadiusXl = BorderRadius.all(
    Radius.circular(radiusXl),
  );

  /// Double extra large border radius
  static const BorderRadius borderRadiusXxl = BorderRadius.all(
    Radius.circular(radiusXxl),
  );

  /// Triple extra large border radius
  static const BorderRadius borderRadiusXxxl = BorderRadius.all(
    Radius.circular(radiusXxxl),
  );

  /// Full border radius (circular)
  static const BorderRadius borderRadiusFull = BorderRadius.all(
    Radius.circular(radiusFull),
  );
}
