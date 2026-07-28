// Package imports:
import 'package:flutter/material.dart';

// Core imports:
import '/core/design_system/borders.dart';
import '/core/design_system/colors.dart';
import '/core/design_system/typography.dart';

/// ═══════════════════════════════════════════════════════════════════════
/// GAWLA — APP THEME
/// ═══════════════════════════════════════════════════════════════════════
///
/// This file's only job is translation: it takes [AppColors] — the
/// game's single source of visual truth — and wires it into every
/// Material widget slot Flutter exposes, so `ElevatedButton`,
/// `TextField`, `Card`, `SnackBar`, `NavigationBar`, and friends look
/// like native Gawla UI out of the box, with zero per-screen styling.
///
/// Rules this file follows:
/// - Every color traces back to a [AppColors] constant. Nothing here
///   introduces a new hex value or a second visual language.
/// - Where Material *requires* a concept [AppColors] intentionally
///   doesn't define (e.g. `ColorScheme.primaryContainer`), it is
///   *derived* from existing semantic colors via [_containerTone]
///   rather than invented — see that helper for details.
/// - Material 3's default "elevation tint" (surfaces get tinted with
///   `colorScheme.primary` as they elevate) is turned off everywhere
///   (`surfaceTintColor: Colors.transparent`). Gawla's depth language is
///   already expressed through [AppColors]' own surface steps
///   (surfaceDefault → surfaceElevated → cardSelected, etc.), so letting
///   Material additionally wash elevated widgets in violet would fight
///   the palette instead of using it.
/// - Shapes lean toward chunky, rounded corners (party-game energy)
///   rather than Material's sharper defaults — geometry only, no color
///   decisions live in the shape constants below.
/// ═══════════════════════════════════════════════════════════════════════
class AppTheme {
  const AppTheme._();

  // ═════════════════════════════════════════════════════════════════════
  // PUBLIC ENTRY POINT
  // ═════════════════════════════════════════════════════════════════════

  /// The game's single [ThemeData]. Pass this straight into
  /// `MaterialApp(theme: AppTheme.theme)`.
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: _colorScheme,

      // ── Typography ───────────────────────────────────────────────────
      fontFamily: AppTypography.bodyFontFamily,
      fontFamilyFallback: const [AppTypography.headingFontFamily],

      // ── App-wide surfaces ────────────────────────────────────────────
      scaffoldBackgroundColor: AppColors.backgroundPrimary,
      canvasColor: AppColors.backgroundPrimary,
      cardColor: AppColors.cardDefault,
      dialogTheme: _dialogTheme,
      dividerColor: AppColors.borderSubtle,

      // ── Global interaction feedback ─────────────────────────────────
      // A physical ripple (rather than the flatter "fade" splash) reads
      // as more tactile and game-like on every tap surface by default.
      splashFactory: InkRipple.splashFactory,
      splashColor: AppColors.overlayPressed,
      highlightColor: AppColors.overlayHover,
      hoverColor: AppColors.overlayHover,
      focusColor: AppColors.borderFocused,
      disabledColor: AppColors.textDisabled,
      shadowColor: AppColors.shadowMedium,
      visualDensity: VisualDensity.standard,

      // ── Iconography & type ──────────────────────────────────────────
      iconTheme: const IconThemeData(color: AppColors.iconDefault),
      primaryIconTheme: const IconThemeData(color: AppColors.iconOnBrand),
      textTheme: _textTheme,
      primaryTextTheme: _textTheme,

      // ── Component themes ────────────────────────────────────────────
      appBarTheme: _appBarTheme,
      elevatedButtonTheme: _elevatedButtonTheme,
      filledButtonTheme: _filledButtonTheme,
      outlinedButtonTheme: _outlinedButtonTheme,
      textButtonTheme: _textButtonTheme,
      iconButtonTheme: _iconButtonTheme,
      floatingActionButtonTheme: _floatingActionButtonTheme,
      inputDecorationTheme: _inputDecorationTheme,
      cardTheme: _cardTheme,
      bottomSheetTheme: _bottomSheetTheme,
      snackBarTheme: _snackBarTheme,
      popupMenuTheme: _popupMenuTheme,
      menuTheme: _menuTheme,
      chipTheme: _chipTheme,
      progressIndicatorTheme: _progressIndicatorTheme,
      dividerTheme: _dividerTheme,
      switchTheme: _switchTheme,
      checkboxTheme: _checkboxTheme,
      radioTheme: _radioTheme,
      sliderTheme: _sliderTheme,
      tabBarTheme: _tabBarTheme,
      navigationBarTheme: _navigationBarTheme,
      bottomNavigationBarTheme: _bottomNavigationBarTheme,
      tooltipTheme: _tooltipTheme,
      badgeTheme: _badgeTheme,
      listTileTheme: _listTileTheme,
      scrollbarTheme: _scrollbarTheme,
      drawerTheme: _drawerTheme,
    );
  }

  /// Not a [ThemeData] field — Flutter reads the modal barrier color from
  /// the call site (`showDialog`, `showModalBottomSheet`), not the theme.
  /// Use this constant there so the scrim still comes from
  /// [AppColors] instead of being re-hardcoded per call:
  /// `showDialog(barrierColor: AppTheme.barrierColor, ...)`.
  static const Color barrierColor = AppColors.overlayScrim;

  // ═════════════════════════════════════════════════════════════════════
  // COLOR SCHEME
  // Material widgets we don't (or can't) theme individually — Slider
  // thumbs, Switch internals, text-selection handles, default splash
  // tints — fall back to `Theme.of(context).colorScheme`. Every field is
  // mapped deliberately so that fallback still looks like Gawla.
  // ═════════════════════════════════════════════════════════════════════

  static ColorScheme get _colorScheme => ColorScheme(
    brightness: Brightness.dark,

    // Brand
    primary: AppColors.brandPrimary,
    onPrimary: AppColors.textOnBrand,
    primaryContainer: _containerTone(AppColors.brandPrimary),
    onPrimaryContainer: AppColors.textPrimary,

    secondary: AppColors.brandSecondary,
    onSecondary: AppColors.textOnBrand,
    secondaryContainer: _containerTone(AppColors.brandSecondary),
    onSecondaryContainer: AppColors.textPrimary,

    // Cyan is Gawla's "live / active" accent — mapped to Material's
    // tertiary slot, which several widgets (e.g. segmented controls)
    // use for a third accent distinct from primary/secondary.
    tertiary: AppColors.brandAccentCyan,
    onTertiary: AppColors.textInverse,
    tertiaryContainer: _containerTone(AppColors.brandAccentCyan),
    onTertiaryContainer: AppColors.textPrimary,

    error: AppColors.statusError,
    onError: AppColors.textOnBrand,
    errorContainer: _containerTone(AppColors.statusError),
    onErrorContainer: AppColors.textPrimary,

    // Surfaces
    surface: AppColors.backgroundPrimary,
    onSurface: AppColors.textPrimary,
    surfaceContainerLowest: AppColors.backgroundArena,
    surfaceContainerLow: AppColors.backgroundSecondary,
    surfaceContainer: AppColors.surfaceDefault,
    surfaceContainerHigh: AppColors.surfaceElevated,
    surfaceContainerHighest: AppColors.cardSelected,
    onSurfaceVariant: AppColors.textSecondary,
    surfaceTint: AppColors.brandPrimary,

    outline: AppColors.borderDefault,
    outlineVariant: AppColors.borderSubtle,
    shadow: AppColors.shadowStrong,
    scrim: AppColors.overlayScrim,

    inverseSurface: AppColors.textPrimary,
    onInverseSurface: AppColors.textInverse,
    inversePrimary: AppColors.brandPrimaryLight,
  );

  /// Derives a Material "container" tone from a [AppColors] accent by
  /// blending it, at low opacity, into a Gawla surface — instead of
  /// inventing a brand-new named color. This keeps every container tone
  /// mathematically tied back to the color system: change the accent in
  /// [AppColors] and every container derived from it updates too.
  static Color _containerTone(Color accent) {
    return Color.alphaBlend(
      accent.withValues(alpha: 0.18),
      AppColors.surfaceDefault,
    );
  }

  // ═════════════════════════════════════════════════════════════════════
  // TYPOGRAPHY
  // Every Material text role maps directly to AppTypography, making it
  // the single source of truth for fonts, sizes, weights, spacing, and
  // default colors. The theme simply exposes those styles through
  // Flutter's TextTheme so Material widgets automatically use Gawla's
  // typography without redefining any text styles here.
  // ═════════════════════════════════════════════════════════════════════

  static const TextTheme _textTheme = TextTheme(
    displayLarge: AppTypography.displayLarge,
    displayMedium: AppTypography.displayMedium,
    displaySmall: AppTypography.displaySmall,

    headlineLarge: AppTypography.headlineLarge,
    headlineMedium: AppTypography.headlineMedium,
    headlineSmall: AppTypography.headlineSmall,

    titleLarge: AppTypography.titleLarge,
    titleMedium: AppTypography.titleMedium,
    titleSmall: AppTypography.titleSmall,

    bodyLarge: AppTypography.bodyLarge,
    bodyMedium: AppTypography.bodyMedium,
    bodySmall: AppTypography.bodySmall,

    labelLarge: AppTypography.labelLarge,
    labelMedium: AppTypography.labelMedium,
    labelSmall: AppTypography.labelSmall,
  );

  // ═════════════════════════════════════════════════════════════════════
  // APP BAR
  // ═════════════════════════════════════════════════════════════════════

  static AppBarTheme get _appBarTheme => const AppBarTheme(
    backgroundColor: AppColors.surfaceDefault,
    foregroundColor: AppColors.textPrimary,
    elevation: 0,
    scrolledUnderElevation: 0,
    // Disabled so scrolling content doesn't tint the app bar with
    // colorScheme.primary — the app bar's flat surfaceDefault color
    // is already the intended "always this color" treatment.
    surfaceTintColor: Colors.transparent,
    centerTitle: true,
    titleTextStyle: TextStyle(
      color: AppColors.textPrimary,
      fontSize: 20,
      fontWeight: FontWeight.w700,
    ),
    iconTheme: IconThemeData(color: AppColors.iconDefault),
    actionsIconTheme: IconThemeData(color: AppColors.iconDefault),
  );

  // ═════════════════════════════════════════════════════════════════════
  // BUTTONS
  // Every button family gets explicit default/pressed/disabled colors so
  // touch feedback is consistent everywhere, using AppColors' own
  // button constants rather than opacity tricks on top of brand colors.
  // ═════════════════════════════════════════════════════════════════════

  /// The primary CTA — "Play", "Create Room", "Join Tournament".
  static ElevatedButtonThemeData get _elevatedButtonTheme {
    return ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return AppColors.buttonPrimaryDisabled;
          }
          if (states.contains(WidgetState.pressed)) {
            return AppColors.buttonPrimaryPressed;
          }
          return AppColors.buttonPrimaryDefault;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return AppColors.textDisabled;
          }
          return AppColors.textOnBrand;
        }),
        overlayColor: const WidgetStatePropertyAll(AppColors.rippleOnBrand),
        shadowColor: const WidgetStatePropertyAll(AppColors.shadowBrandGlow),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        elevation: const WidgetStatePropertyAll(4),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        ),
        shape: const WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: AppBorders.borderRadiusFull),
        ),
        textStyle: const WidgetStatePropertyAll(
          TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ),
    );
  }

  /// Material 3's `FilledButton` — styled identically to [ElevatedButton]
  /// so designers/devs can reach for either widget interchangeably and
  /// still get the same primary-CTA look.
  static FilledButtonThemeData get _filledButtonTheme {
    return FilledButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return AppColors.buttonPrimaryDisabled;
          }
          if (states.contains(WidgetState.pressed)) {
            return AppColors.buttonPrimaryPressed;
          }
          return AppColors.buttonPrimaryDefault;
        }),
        foregroundColor: const WidgetStatePropertyAll(AppColors.textOnBrand),
        overlayColor: const WidgetStatePropertyAll(AppColors.rippleOnBrand),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        ),
        shape: const WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: AppBorders.borderRadiusFull),
        ),
        textStyle: const WidgetStatePropertyAll(
          TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ),
    );
  }

  /// Secondary actions that shouldn't out-compete the primary CTA —
  /// "Cancel", "Invite Friends" next to "Play".
  static OutlinedButtonThemeData get _outlinedButtonTheme {
    return OutlinedButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return AppColors.textDisabled;
          }
          return AppColors.textPrimary;
        }),
        overlayColor: const WidgetStatePropertyAll(AppColors.overlayHover),
        side: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return const BorderSide(color: AppColors.borderSubtle);
          }
          if (states.contains(WidgetState.pressed)) {
            return const BorderSide(
              color: AppColors.borderSelected,
              width: 1.5,
            );
          }
          return const BorderSide(color: AppColors.borderDefault);
        }),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        ),
        shape: const WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: AppBorders.borderRadiusFull),
        ),
        textStyle: const WidgetStatePropertyAll(
          TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ),
    );
  }

  /// Low-emphasis actions — "Skip", "Learn more", dialog dismiss actions.
  static TextButtonThemeData get _textButtonTheme {
    return TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return AppColors.textDisabled;
          }
          if (states.contains(WidgetState.pressed)) {
            return AppColors.brandPrimaryLight;
          }
          return AppColors.brandAccentCyan;
        }),
        overlayColor: const WidgetStatePropertyAll(AppColors.overlayHover),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        shape: const WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: AppBorders.borderRadiusMd),
        ),
        textStyle: const WidgetStatePropertyAll(
          TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
    );
  }

  /// Icon-only tap targets — nav bar icons, close buttons, mute toggles.
  static IconButtonThemeData get _iconButtonTheme {
    return IconButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return AppColors.iconMuted;
          }
          if (states.contains(WidgetState.selected)) {
            return AppColors.iconActive;
          }
          return AppColors.iconDefault;
        }),
        overlayColor: const WidgetStatePropertyAll(AppColors.overlayHover),
      ),
    );
  }

  /// Floating action button — used sparingly for a single dominant
  /// screen action (e.g. a quick-play shortcut). Uses the secondary
  /// "jolt" color so it reads as a distinct, energetic action rather
  /// than competing with a primary CTA already on screen.
  static FloatingActionButtonThemeData get _floatingActionButtonTheme {
    return const FloatingActionButtonThemeData(
      backgroundColor: AppColors.brandSecondary,
      foregroundColor: AppColors.textOnBrand,
      splashColor: AppColors.rippleOnBrand,
      elevation: 6,
      focusElevation: 6,
      hoverElevation: 8,
      shape: RoundedRectangleBorder(borderRadius: AppBorders.borderRadiusXxxl),
    );
  }

  // ═════════════════════════════════════════════════════════════════════
  // INPUTS
  // Recessed "carved into the screen" fields, matching
  // AppColors.surfaceSunken's intent, with cyan (the "active" accent)
  // marking focus so it's unmistakable on a dark, saturated background.
  // ═════════════════════════════════════════════════════════════════════

  static InputDecorationTheme get _inputDecorationTheme {
    OutlineInputBorder border(Color color, {double width = 1.5}) {
      return OutlineInputBorder(
        borderRadius: AppBorders.borderRadiusXl,
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceSunken,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: border(AppColors.borderDefault),
      enabledBorder: border(AppColors.borderDefault),
      focusedBorder: border(AppColors.borderFocused, width: 2),
      errorBorder: border(AppColors.borderError),
      focusedErrorBorder: border(AppColors.borderError, width: 2),
      disabledBorder: border(AppColors.borderSubtle),
      labelStyle: const TextStyle(color: AppColors.textSecondary),
      floatingLabelStyle: const TextStyle(color: AppColors.brandAccentCyan),
      hintStyle: const TextStyle(color: AppColors.textTertiary),
      helperStyle: const TextStyle(color: AppColors.textTertiary),
      errorStyle: const TextStyle(color: AppColors.statusError),
      prefixIconColor: AppColors.iconMuted,
      suffixIconColor: AppColors.iconMuted,
    );
  }

  // ═════════════════════════════════════════════════════════════════════
  // CARDS
  // ═════════════════════════════════════════════════════════════════════

  static CardThemeData get _cardTheme => const CardThemeData(
    color: AppColors.cardDefault,
    surfaceTintColor: Colors.transparent,
    shadowColor: AppColors.shadowSoft,
    elevation: 2,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(borderRadius: AppBorders.borderRadiusXl),
  );

  // ═════════════════════════════════════════════════════════════════════
  // DIALOGS & BOTTOM SHEETS
  // Both use surfaceElevated so any "floating above the screen" content
  // reads consistently, whichever widget presents it.
  // ═════════════════════════════════════════════════════════════════════

  static DialogThemeData get _dialogTheme => const DialogThemeData(
    backgroundColor: AppColors.surfaceElevated,
    surfaceTintColor: Colors.transparent,
    elevation: 8,
    shadowColor: AppColors.shadowStrong,
    shape: RoundedRectangleBorder(borderRadius: AppBorders.borderRadiusXxxl),
    titleTextStyle: TextStyle(
      color: AppColors.textPrimary,
      fontSize: 20,
      fontWeight: FontWeight.w700,
    ),
    contentTextStyle: TextStyle(color: AppColors.textSecondary, fontSize: 15),
  );

  static BottomSheetThemeData get _bottomSheetTheme =>
      const BottomSheetThemeData(
        backgroundColor: AppColors.surfaceElevated,
        modalBackgroundColor: AppColors.surfaceElevated,
        surfaceTintColor: Colors.transparent,
        modalBarrierColor: AppColors.overlayScrim,
        dragHandleColor: AppColors.borderDefault,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppBorders.radiusXxxl),
          ),
        ),
      );

  // ═════════════════════════════════════════════════════════════════════
  // SNACK BARS
  // Default is neutral (surfaceElevated) for general toasts — "Room
  // created", "Copied invite code". For outcome-specific toasts, pass
  // AppColors.statusSuccess / statusError / statusWarning as that
  // particular SnackBar's backgroundColor to override the default.
  // ═════════════════════════════════════════════════════════════════════

  static SnackBarThemeData get _snackBarTheme => const SnackBarThemeData(
    backgroundColor: AppColors.surfaceElevated,
    contentTextStyle: TextStyle(color: AppColors.textPrimary),
    actionTextColor: AppColors.brandAccentCyan,
    disabledActionTextColor: AppColors.textDisabled,
    behavior: SnackBarBehavior.floating,
    elevation: 6,
    insetPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    shape: RoundedRectangleBorder(borderRadius: AppBorders.borderRadiusXl),
  );

  // ═════════════════════════════════════════════════════════════════════
  // MENUS
  // ═════════════════════════════════════════════════════════════════════

  static PopupMenuThemeData get _popupMenuTheme => const PopupMenuThemeData(
    color: AppColors.surfaceElevated,
    surfaceTintColor: Colors.transparent,
    elevation: 6,
    shape: RoundedRectangleBorder(borderRadius: AppBorders.borderRadiusMd),
    textStyle: TextStyle(color: AppColors.textPrimary, fontSize: 15),
  );

  static MenuThemeData get _menuTheme => const MenuThemeData(
    style: MenuStyle(
      backgroundColor: WidgetStatePropertyAll(AppColors.surfaceElevated),
      surfaceTintColor: WidgetStatePropertyAll(Colors.transparent),
      elevation: WidgetStatePropertyAll(6),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: AppBorders.borderRadiusMd),
      ),
    ),
  );

  // ═════════════════════════════════════════════════════════════════════
  // CHIPS
  // Used for room tags (Public/Private), filters, and rarity/category
  // labels on shop or inventory items.
  // ═════════════════════════════════════════════════════════════════════

  static ChipThemeData get _chipTheme => const ChipThemeData(
    backgroundColor: AppColors.cardDefault,
    selectedColor: AppColors.cardSelected,
    disabledColor: AppColors.cardDisabled,
    checkmarkColor: AppColors.brandAccentCyan,
    deleteIconColor: AppColors.iconMuted,
    labelStyle: TextStyle(color: AppColors.textPrimary, fontSize: 13),
    secondaryLabelStyle: TextStyle(color: AppColors.textOnBrand, fontSize: 13),
    side: BorderSide(color: AppColors.borderDefault),
    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    shape: RoundedRectangleBorder(borderRadius: AppBorders.borderRadiusFull),
  );

  // ═════════════════════════════════════════════════════════════════════
  // PROGRESS INDICATORS
  // Shared by loading spinners, in-round timers rendered as bars, and
  // any generic "working on it" moment. Round-specific timer coloring
  // (safe/warning/critical) is applied per-instance from
  // AppColors.timer* — this theme only sets the *default* look.
  // ═════════════════════════════════════════════════════════════════════

  static ProgressIndicatorThemeData get _progressIndicatorTheme {
    return const ProgressIndicatorThemeData(
      color: AppColors.loadingIndicator,
      linearTrackColor: AppColors.progressTrackBackground,
      circularTrackColor: AppColors.progressTrackBackground,
      refreshBackgroundColor: AppColors.surfaceElevated,
    );
  }

  // ═════════════════════════════════════════════════════════════════════
  // DIVIDERS
  // ═════════════════════════════════════════════════════════════════════

  static const DividerThemeData _dividerTheme = DividerThemeData(
    color: AppColors.borderSubtle,
    thickness: 1,
    space: 1,
  );

  // ═════════════════════════════════════════════════════════════════════
  // SELECTION CONTROLS
  // Switch, Checkbox, Radio — settings screens (sound, notifications,
  // room options) are the primary home for these.
  // ═════════════════════════════════════════════════════════════════════

  static SwitchThemeData get _switchTheme {
    return SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return AppColors.textDisabled;
        }
        if (states.contains(WidgetState.selected)) {
          return AppColors.textOnBrand;
        }
        return AppColors.textSecondary;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return AppColors.surfaceSunken;
        }
        if (states.contains(WidgetState.selected)) {
          return AppColors.brandPrimary;
        }
        return AppColors.borderDefault;
      }),
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
    );
  }

  static CheckboxThemeData get _checkboxTheme {
    return CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return AppColors.surfaceSunken;
        }
        if (states.contains(WidgetState.selected)) {
          return AppColors.brandPrimary;
        }
        return Colors.transparent;
      }),
      checkColor: const WidgetStatePropertyAll(AppColors.textOnBrand),
      side: const BorderSide(color: AppColors.borderDefault, width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
    );
  }

  static RadioThemeData get _radioTheme {
    return RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return AppColors.textDisabled;
        }
        if (states.contains(WidgetState.selected)) {
          return AppColors.brandPrimary;
        }
        return AppColors.borderDefault;
      }),
    );
  }

  static SliderThemeData get _sliderTheme {
    return SliderThemeData(
      activeTrackColor: AppColors.brandPrimary,
      inactiveTrackColor: AppColors.progressTrackBackground,
      thumbColor: AppColors.brandPrimary,
      overlayColor: AppColors.brandPrimary.withValues(alpha: 0.16),
      valueIndicatorColor: AppColors.surfaceElevated,
      valueIndicatorTextStyle: const TextStyle(color: AppColors.textPrimary),
      disabledActiveTrackColor: AppColors.textDisabled,
      disabledInactiveTrackColor: AppColors.surfaceSunken,
      disabledThumbColor: AppColors.textDisabled,
    );
  }

  // ═════════════════════════════════════════════════════════════════════
  // TABS
  // ═════════════════════════════════════════════════════════════════════

  static TabBarThemeData get _tabBarTheme => const TabBarThemeData(
    labelColor: AppColors.textPrimary,
    unselectedLabelColor: AppColors.textTertiary,
    labelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
    unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
    indicatorColor: AppColors.brandAccentCyan,
    dividerColor: AppColors.borderSubtle,
    overlayColor: WidgetStatePropertyAll(AppColors.overlayHover),
  );

  // ═════════════════════════════════════════════════════════════════════
  // NAVIGATION
  // NavigationBar (Material 3 bottom nav) is the primary target;
  // BottomNavigationBar is themed too for any screen still using the
  // legacy widget, so the two never visually disagree.
  // ═════════════════════════════════════════════════════════════════════

  static NavigationBarThemeData get _navigationBarTheme {
    return NavigationBarThemeData(
      backgroundColor: AppColors.surfaceDefault,
      surfaceTintColor: Colors.transparent,
      indicatorColor: AppColors.cardSelected,
      elevation: 0,
      height: 68,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          fontSize: 12,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
          color: selected ? AppColors.textPrimary : AppColors.textTertiary,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: selected ? AppColors.brandAccentCyan : AppColors.iconMuted,
        );
      }),
    );
  }

  static BottomNavigationBarThemeData get _bottomNavigationBarTheme {
    return const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surfaceDefault,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.brandAccentCyan,
      unselectedItemColor: AppColors.iconMuted,
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
      unselectedLabelStyle: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
    );
  }

  static DrawerThemeData get _drawerTheme => const DrawerThemeData(
    backgroundColor: AppColors.surfaceDefault,
    surfaceTintColor: Colors.transparent,
    elevation: 8,
    shadowColor: AppColors.shadowStrong,
  );

  // ═════════════════════════════════════════════════════════════════════
  // TOOLTIPS
  // ═════════════════════════════════════════════════════════════════════

  static TooltipThemeData get _tooltipTheme => TooltipThemeData(
    decoration: BoxDecoration(
      color: AppColors.surfaceElevated,
      borderRadius: AppBorders.borderRadiusMd,
      border: Border.all(color: AppColors.borderDefault),
    ),
    textStyle: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
  );

  // ═════════════════════════════════════════════════════════════════════
  // BADGES
  // Maps directly onto AppColors' own notification-badge colors —
  // this is the one Material slot that already had a 1:1 semantic
  // match in the design system.
  // ═════════════════════════════════════════════════════════════════════

  static BadgeThemeData get _badgeTheme => const BadgeThemeData(
    backgroundColor: AppColors.badgeCountBackground,
    textColor: AppColors.badgeCountText,
    smallSize: 8,
    largeSize: 16,
    textStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
  );

  // ═════════════════════════════════════════════════════════════════════
  // LISTS & SCROLLING
  // ═════════════════════════════════════════════════════════════════════

  static ListTileThemeData get _listTileTheme => const ListTileThemeData(
    tileColor: Colors.transparent,
    selectedTileColor: AppColors.cardSelected,
    iconColor: AppColors.iconDefault,
    textColor: AppColors.textPrimary,
    selectedColor: AppColors.brandPrimaryLight,
    shape: RoundedRectangleBorder(borderRadius: AppBorders.borderRadiusMd),
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
  );

  static ScrollbarThemeData get _scrollbarTheme {
    return ScrollbarThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.dragged)) {
          return AppColors.brandPrimaryLight;
        }
        if (states.contains(WidgetState.hovered)) {
          return AppColors.borderSelected;
        }
        return AppColors.borderDefault;
      }),
      radius: const Radius.circular(AppBorders.radiusFull),
      thickness: const WidgetStatePropertyAll(6),
    );
  }
}
