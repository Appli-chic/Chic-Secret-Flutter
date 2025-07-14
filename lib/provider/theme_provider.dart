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
  primaryColor: Color(0xFF4CAF50),
  secondaryColor: Color(0xFF4CAF50),
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

  _generateThemeList() {
    _themeList.add(defaultDarkTheme);
  }

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

  setTheme(int id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _theme = _themeList.where((theme) => theme.id == id).toList()[0];

    await prefs.setInt(keyTheme, id);

    notifyListeners();
  }

  Brightness getBrightness() {
    if (theme.isLight) {
      return Brightness.light;
    } else {
      return Brightness.dark;
    }
  }

  ChicTheme get theme => _theme;

  Color get backgroundColor => ChicPlatform.isDesktop()
      ? _theme.backgroundDesktopColor
      : _theme.backgroundColor;

  Color get sidebarBackgroundColor => _theme.sidebarBackgroundColor;

  Color get secondBackgroundColor => ChicPlatform.isDesktop()
      ? _theme.secondBackgroundDesktopColor
      : _theme.secondBackgroundColor;

  Color get modalBackgroundColor => _theme.modalBackgroundColor;

  Color get selectionBackground => _theme.selectionBackground;

  Color get inputBackgroundColor => _theme.inputBackgroundColor;

  Color get primaryColor => _theme.primaryColor;

  Color get secondaryColor => _theme.secondaryColor;

  Color get textColor => _theme.textColor;

  Color get secondTextColor => _theme.secondTextColor;

  Color get thirdTextColor => _theme.thirdTextColor;

  Color get placeholder => _theme.placeholder;

  Color get divider => _theme.divider;

  Color get labelColor => _theme.labelColor;

  bool get isLight => _theme.isLight;
}
