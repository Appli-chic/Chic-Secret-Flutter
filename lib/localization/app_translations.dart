import 'dart:async';
import 'dart:convert';
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

  /// Load the [locale] language to display text
  static Future<AppTranslations> load(Locale locale) async {
    AppTranslations appTranslations = AppTranslations(locale);

    try {
      String jsonContent = await rootBundle.loadString(
          "assets/languages/localization_${locale.languageCode}.json");
      _localisedValues = json.decode(jsonContent);
    } catch (e) {
      String jsonContent =
          await rootBundle.loadString("assets/languages/localization_en.json");
      _localisedValues = json.decode(jsonContent);

      print(e);
    }

    return appTranslations;
  }

  /// Get the current [locale] language we are display text with
  get currentLanguage => locale.languageCode;

  /// Get the text corresponding to the current locale stored in the [key]
  String text(String key) {
    if (_localisedValues != null) {
      return _localisedValues![key];
    } else {
      return key;
    }
  }

  /// Get the list of text corresponding to the current locale stored in the [key]
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

  /// Get the text corresponding to the current locale stored in the [key]
  /// replacing {} with the [arg]
  String textWithArgument(String key, String arg) {
    if (_localisedValues != null) {
      return _localisedValues![key].toString().replaceFirst('{}', arg);
    } else {
      return key;
    }
  }

  /// Get the text corresponding to the current locale stored in the [key]
  /// replacing the {} with the [args]
  String textWithArguments(String key, List<String> args) {
    if (_localisedValues != null) {
      return _localisedValues![key];
    } else {
      return key;
    }
  }
}
