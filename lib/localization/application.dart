import 'dart:ui';

class Application {
  static final Application _application = Application._internal();

  factory Application() {
    return _application;
  }

  Application._internal();

  static List<String> supportedLanguages = [
    "English",
    "Français",
    "Español",
  ];

  static List<String> supportedLanguagesCodes = [
    "en",
    "fr",
    "es",
  ];

  /// Get the language name from it's code
  static String getSupportedLanguageFromCode(String? code) {
    if (supportedLanguagesCodes.contains(code)) {
      var index = supportedLanguagesCodes.indexOf(code!);
      return supportedLanguages[index];
    } else {
      return "English";
    }
  }

  /// Returns the list of supported Locales
  Iterable<Locale> supportedLocales() =>
      supportedLanguagesCodes.map<Locale>((language) => Locale(language, ""));
}

Application application = Application();
