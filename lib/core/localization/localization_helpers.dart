// Package imports:
import 'package:flutter/material.dart';

// Core imports:
import '/core/localization/generated/app_localizations.dart';

// Convenience extensions on [BuildContext] for localization.
extension LocalizationExtension on BuildContext {
  // Short-hand accessor for [AppLocalizations].
  AppLocalizations get l10n => AppLocalizations.of(this)!;

  // The active [Locale] for this context.
  Locale get locale => Localizations.localeOf(this);

  // `true` when the current locale uses a right-to-left script.
  bool get isRTL => locale.languageCode == 'ar';

  // The [TextDirection] derived from the current locale.
  TextDirection get textDirection =>
      isRTL ? TextDirection.rtl : TextDirection.ltr;
}
