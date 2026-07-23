// Package imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Core imports:
import '/core/localization/generated/app_localizations.dart';

// Custom localization delegate for the app.
class AppLocalizationDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationDelegate();

  @override
  bool isSupported(Locale locale) =>
      AppLocalizations.supportedLocales.contains(locale);

  @override
  Future<AppLocalizations> load(Locale locale) =>
      SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));

  @override
  bool shouldReload(AppLocalizationDelegate old) => false;
}

// Central localization configuration — pass these directly to [MaterialApp].
class LocalizationConfig {
  const LocalizationConfig._();

  static const List<Locale> supportedLocales = [
    Locale('en'), // English
    Locale('ar'), // Arabic
  ];

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  // Returns the device locale when supported, otherwise falls back to English.
  static Locale getDeviceLocale() {
    final deviceLocale = PlatformDispatcher.instance.locale;
    if (supportedLocales.contains(deviceLocale)) return deviceLocale;
    return const Locale('en');
  }

  // Returns `true` when [locale] uses a right-to-left script.
  static bool isRTL(Locale locale) => locale.languageCode == 'ar';

  // Returns the [TextDirection] for [locale].
  static TextDirection getTextDirection(Locale locale) =>
      isRTL(locale) ? TextDirection.rtl : TextDirection.ltr;
}
