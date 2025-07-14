import 'package:chic_secret/model/theme.dart';
import 'package:chic_secret/utils/chic_platform.dart';
import 'package:chic_secret/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const int DEFAULT_THEME_DARK = 0;
const int DEFAULT_THEME_LIGHT = 1;

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

ChicTheme defaultLightTheme = ChicTheme(
  id: DEFAULT_THEME_LIGHT,
  backgroundColor: Color(0xFFFFFFFF),
  backgroundDesktopColor: Color(0xFFF5F5F7),
  secondBackgroundColor: Color(0xFFF2F2F7),
  secondBackgroundDesktopColor: Color(0xFFE5E5EA),
  sidebarBackgroundColor: Color(0xFFE5E5EA),
  modalBackgroundColor: Color(0xFFF2F2F7),
  selectionBackground: Color(0xFFD1E7DD),
  inputBackgroundColor: Color(0xFFF2F2F7),
  primaryColor: Color(0xFF4CAF50),
  secondaryColor: Color(0xFF4CAF50),
  textColor: Color(0xFF000000),
  secondTextColor: Color(0x99000000),
  thirdTextColor: Color(0x4D000000),
  placeholder: Color(0x4D000000),
  labelColor: Color(0xFF646265),
  divider: Color(0x99545458),
  isLight: true,
);

class ThemeProvider with ChangeNotifier {
  ChicTheme _theme = defaultDarkTheme;

  ThemeProvider() {
    var brightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;

    if (brightness == Brightness.light) {
      _theme = defaultLightTheme;
    } else {
      _theme = defaultDarkTheme;
    }

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
