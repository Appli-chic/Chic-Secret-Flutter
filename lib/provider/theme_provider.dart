import 'package:chic_secret/model/theme.dart';
import 'package:chic_secret/utils/chic_platform.dart';
import 'package:chic_secret/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const int DEFAULT_THEME_DARK = 0;

ChicTheme defaultDarkTheme = ChicTheme(
  id: DEFAULT_THEME_DARK,
  backgroundColor: Color(0xFF000000),
  backgroundDesktopColor: Color(0xFF222026),
  secondBackgroundColor: Color(0xFF1C1C1E),
  secondBackgroundDesktopColor: Color(0xFF292829),
  sidebarBackgroundColor: Color(0xFF29262b),
  modalBackgroundColor: Color(0xFF2a2a2d),
  selectionBackground: Color(0xFF403d41),
  inputBackgroundColor: Color(0xFF292829),
  primaryColor: Color(0xFF9C27B0),
  secondaryColor: Color(0xFF7B1FA2),
  textColor: Color(0xFFFFFFFF),
  secondTextColor: Color(0x99EBEBF5),
  thirdTextColor: Color(0x4DEBEBF5),
  placeholder: Color(0x4DEBEBF5),
  labelColor: Color(0xFF646265),
  divider: Color(0x99545458),
  isLight: false,
);

class ThemeProvider with ChangeNotifier {
  List<ChicTheme> _themeList = [];
  ChicTheme _theme = defaultDarkTheme;

  ThemeProvider() {
    _generateThemeList();
    _theme = _themeList[0];
    _loadTheme();
  }

  /// Generates the list of themes and insert it in the [_themeList].
  _generateThemeList() {
    _themeList.add(defaultDarkTheme);
  }

  /// Load the [_theme] stored in the secured storage
  _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? _themeString = prefs.getInt(keyTheme);

    if (_themeString != null) {
      // Load the theme if it exists
      _theme =
          _themeList.where((theme) => theme.id == _themeString).toList()[0];
    }

    notifyListeners();
  }

  /// Set the new theme using the [id] of the [_theme]
  setTheme(int id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _theme = _themeList.where((theme) => theme.id == id).toList()[0];

    await prefs.setInt(keyTheme, id);

    notifyListeners();
  }

  /// Set the brightness from the actual [_theme]
  Brightness getBrightness() {
    if (theme.isLight) {
      return Brightness.light;
    } else {
      return Brightness.dark;
    }
  }

  /// Retrieve the background color corresponding to the [_theme]
  ChicTheme get theme => _theme;

  /// Retrieve the background color corresponding to the [_theme]
  Color get backgroundColor => ChicPlatform.isDesktop()
      ? _theme.backgroundDesktopColor
      : _theme.backgroundColor;

  // Retrieve the sidebar color corresponding to the [_theme]
  Color get sidebarBackgroundColor => _theme.sidebarBackgroundColor;

  // Retrieve the second background color corresponding to the [_theme]
  Color get secondBackgroundColor => ChicPlatform.isDesktop()
      ? _theme.secondBackgroundDesktopColor
      : _theme.secondBackgroundColor;

  // Retrieve the modal background color corresponding to the [_theme]
  Color get modalBackgroundColor => _theme.modalBackgroundColor;

  // Retrieve the selection background color corresponding to the [_theme]
  Color get selectionBackground => _theme.selectionBackground;

  // Retrieve the input background color corresponding to the [_theme]
  Color get inputBackgroundColor => _theme.inputBackgroundColor;

  /// Retrieve the first color corresponding to the [_theme]
  Color get primaryColor => _theme.primaryColor;

  /// Retrieve the second color corresponding to the [_theme]
  Color get secondaryColor => _theme.secondaryColor;

  /// Retrieve the text color corresponding to the [_theme]
  Color get textColor => _theme.textColor;

  /// Retrieve the second text color corresponding to the [_theme]
  Color get secondTextColor => _theme.secondTextColor;

  /// Retrieve the third text color corresponding to the [_theme]
  Color get thirdTextColor => _theme.thirdTextColor;

  /// Retrieve the placeholder color corresponding to the [_theme]
  Color get placeholder => _theme.placeholder;

  /// Retrieve the divider color corresponding to the [_theme]
  Color get divider => _theme.divider;

  /// Retrieve the label color corresponding to the [_theme]
  Color get labelColor => _theme.labelColor;

  /// Retrieve if the theme is a light [_theme]
  bool get isLight => _theme.isLight;
}
