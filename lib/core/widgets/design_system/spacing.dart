import 'package:flutter/widgets.dart';

abstract final class AppSpacing {
  const AppSpacing._();

  // ── BASE UNIT ──────────────────────────────────────────────────────────────

  /// Base spacing unit (8px) - all spacing values are multiples of this
  static const double baseUnit = 8.0;

  // ── SPACING SCALE ──────────────────────────────────────────────────────────

  /// No spacing (0px)
  static const double none = 0.0;

  /// Extra small spacing (4px) - 0.5 * baseUnit
  static const double xs = baseUnit * 0.5;

  /// Small spacing (8px) - 1 * baseUnit
  static const double sm = baseUnit * 1;

  /// Medium spacing (12px) - 1.5 * baseUnit
  static const double md = baseUnit * 1.5;

  /// Large spacing (16px) - 2 * baseUnit
  static const double lg = baseUnit * 2;

  /// Extra large spacing (20px) - 2.5 * baseUnit
  static const double xl = baseUnit * 2.5;

  /// Double extra large spacing (24px) - 3 * baseUnit
  static const double xxl = baseUnit * 3;

  /// Triple extra large spacing (32px) - 4 * baseUnit
  static const double xxxl = baseUnit * 4;

  /// Huge spacing (40px) - 5 * baseUnit
  static const double huge = baseUnit * 5;

  /// Massive spacing (48px) - 6 * baseUnit
  static const double massive = baseUnit * 6;

  /// Giant spacing (64px) - 8 * baseUnit
  static const double giant = baseUnit * 8;

  // ── EDGE INSETS PRESETS ────────────────────────────────────────────────────

  /// No padding (0px)
  static const EdgeInsets paddingNone = EdgeInsets.zero;

  /// Extra small padding (4px)
  static const EdgeInsets paddingXs = EdgeInsets.all(xs);

  /// Small padding (8px)
  static const EdgeInsets paddingSm = EdgeInsets.all(sm);

  /// Medium padding (12px)
  static const EdgeInsets paddingMd = EdgeInsets.all(md);

  /// Large padding (16px)
  static const EdgeInsets paddingLg = EdgeInsets.all(lg);

  /// Extra large padding (20px)
  static const EdgeInsets paddingXl = EdgeInsets.all(xl);

  /// Double extra large padding (24px)
  static const EdgeInsets paddingXxl = EdgeInsets.all(xxl);

  /// Triple extra large padding (32px)
  static const EdgeInsets paddingXxxl = EdgeInsets.all(xxxl);

  /// Huge padding (40px)
  static const EdgeInsets paddingHuge = EdgeInsets.all(huge);

  /// Massive padding (48px)
  static const EdgeInsets paddingMassive = EdgeInsets.all(massive);

  /// Giant padding (64px)
  static const EdgeInsets paddingGiant = EdgeInsets.all(giant);

  // ── SIZED BOX PRESETS ──────────────────────────────────────────────────────

  // Horizontal

  /// Extra small horizontal space (4px)
  static const SizedBox horizontalSpaceXs = SizedBox(width: xs);

  /// Small horizontal space (8px)
  static const SizedBox horizontalSpaceSm = SizedBox(width: sm);

  /// Medium horizontal space (12px)
  static const SizedBox horizontalSpaceMd = SizedBox(width: md);

  /// Large horizontal space (16px)
  static const SizedBox horizontalSpaceLg = SizedBox(width: lg);

  /// Extra large horizontal space (20px)
  static const SizedBox horizontalSpaceXl = SizedBox(width: xl);

  /// Double extra large horizontal space (24px)
  static const SizedBox horizontalSpaceXxl = SizedBox(width: xxl);

  /// Triple extra large horizontal space (32px)
  static const SizedBox horizontalSpaceXxxl = SizedBox(width: xxxl);

  /// Huge horizontal space (40px)
  static const SizedBox horizontalSpaceHuge = SizedBox(width: huge);

  /// Massive horizontal space (48px)
  static const SizedBox horizontalSpaceMassive = SizedBox(width: massive);

  /// Giant horizontal space (64px)
  static const SizedBox horizontalSpaceGiant = SizedBox(width: giant);

  // Vertical

  /// Extra small vertical space (4px)
  static const SizedBox verticalSpaceXs = SizedBox(height: xs);

  /// Small vertical space (8px)
  static const SizedBox verticalSpaceSm = SizedBox(height: sm);

  /// Medium vertical space (12px)
  static const SizedBox verticalSpaceMd = SizedBox(height: md);

  /// Large vertical space (16px)
  static const SizedBox verticalSpaceLg = SizedBox(height: lg);

  /// Extra large vertical space (20px)
  static const SizedBox verticalSpaceXl = SizedBox(height: xl);

  /// Double extra large vertical space (24px)
  static const SizedBox verticalSpaceXxl = SizedBox(height: xxl);

  /// Triple extra large vertical space (32px)
  static const SizedBox verticalSpaceXxxl = SizedBox(height: xxxl);

  /// Huge vertical space (40px)
  static const SizedBox verticalSpaceHuge = SizedBox(height: huge);

  /// Massive vertical space (48px)
  static const SizedBox verticalSpaceMassive = SizedBox(height: massive);

  /// Giant vertical space (64px)
  static const SizedBox verticalSpaceGiant = SizedBox(height: giant);
}
