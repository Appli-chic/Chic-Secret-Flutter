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

  static String getSupportedLanguageFromCode(String? code) {
    if (supportedLanguagesCodes.contains(code)) {
      var index = supportedLanguagesCodes.indexOf(code!);
      return supportedLanguages[index];
    } else {
      return "English";
    }
  }

  Iterable<Locale> supportedLocales() =>
      supportedLanguagesCodes.map<Locale>((language) => Locale(language, ""));
}

Application application = Application();
