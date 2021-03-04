import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class AppTranslations {
  Locale locale = Locale('en', '');
  static Map<dynamic, dynamic>? _localisedValues;

  AppTranslations(Locale locale) {
    this.locale = locale;
  }

  static AppTranslations of(BuildContext context) {
    return Localizations.of<AppTranslations>(context, AppTranslations)!;
  }

  static Future<AppTranslations> load(Locale locale) async {
    AppTranslations appTranslations = AppTranslations(locale);

    String jsonContent = await rootBundle.loadString(
        "assets/languages/localization_${locale.languageCode}.json");
    _localisedValues = json.decode(jsonContent);

    return appTranslations;
  }

  get currentLanguage => locale.languageCode;

  String text(String key) {
    if (_localisedValues != null) {
      return _localisedValues![key];
    } else {
      return key;
    }
  }

  List<String> list(String key) {
    var result = <String>[];

    if (_localisedValues != null) {
      if ((_localisedValues![key] as List<dynamic>).isNotEmpty) {
        for (var element in _localisedValues![key]) {
          result.add(element);
        }
      }
    }

    return result;
  }

  String textWithArgument(String key, String arg) {
    if (_localisedValues != null) {
      return _localisedValues![key].toString().replaceFirst('{}', arg);
    } else {
      return key;
    }
  }

  String textWithArguments(String key, List<String> args) {
    if (_localisedValues != null) {
      return _localisedValues![key];
    } else {
      return key;
    }
  }
}