import 'dart:async';
import 'package:flutter/material.dart';

import 'app_translations.dart';
import 'application.dart';

class AppTranslationsDelegate extends LocalizationsDelegate<AppTranslations> {
  final Locale? newLocale;

  AppTranslationsDelegate({this.newLocale});

  @override
  bool isSupported(Locale locale) {
    return Application.supportedLanguagesCodes.contains(locale.languageCode);
  }

  @override
  Future<AppTranslations> load(Locale locale) {
    return AppTranslations.load(locale);
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppTranslations> old) {
    return true;
  }
}
