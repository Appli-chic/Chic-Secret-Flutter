import 'dart:io';
import 'dart:math';

import 'package:chic_secret/localization/app_translations.dart';
import 'package:chic_secret/localization/application.dart';
import 'package:chic_secret/provider/theme_provider.dart';
import 'package:chic_secret/ui/component/common/chic_elevated_button.dart';
import 'package:chic_secret/ui/component/common/chic_icon_button.dart';
import 'package:chic_secret/ui/component/common/chic_navigator.dart';
import 'package:chic_secret/ui/component/common/chic_text_button.dart';
import 'package:chic_secret/ui/component/common/chic_text_field.dart';
import 'package:chic_secret/ui/component/common/desktop_modal.dart';
import 'package:chic_secret/ui/screen/select_language_screen.dart';
import 'package:chic_secret/utils/chic_platform.dart';
import 'package:chic_secret/utils/constant.dart';
import 'package:chic_secret/utils/rich_text_editing_controller.dart';
import 'package:chic_secret/utils/security.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GeneratePasswordScreen extends StatefulWidget {
  final String previousPageTitle;

  GeneratePasswordScreen({
    required this.previousPageTitle,
  });

  @override
  _GeneratePasswordScreenState createState() => _GeneratePasswordScreenState();
}

class _GeneratePasswordScreenState extends State<GeneratePasswordScreen>
    with TickerProviderStateMixin {
  Locale? _locale;
  late TabController _tabController;
  final _passwordController = RichTextEditingController();
  final _languageController = TextEditingController();
  var _passwordFocusNode = FocusNode();
  var _languageFocusNode = FocusNode();
  var _desktopPasswordFocusNode = FocusNode();
  var _desktopLanguageFocusNode = FocusNode();

  var _isGeneratingWords = true;
  int? _segmentedControlIndex = 0;

  var _hasUppercase = true;
  var _hasNumbers = true;
  var _hasSpecialCharacters = true;

  // if _isGeneratingWords is false then it's the number of characters
  var _numberWords = defaultPasswordWordNumber;
  var _minWords = 1.0;
  var _maxWords = 10.0;
  var _divisionWords = 9;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_locale == null) {
      _locale = Localizations.localeOf(context);
      _passwordController.text = _generatePassword();

      if (_locale != null) {
        _languageController.text =
            Application.getSupportedLanguageFromCode(_locale!.languageCode);
      }
    }

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context, listen: true);

    if (ChicPlatform.isDesktop()) {
      return _displaysDesktopInModal(themeProvider);
    } else {
      return _displaysMobile(themeProvider);
    }
  }

  Widget _displaysDesktopInModal(ThemeProvider themeProvider) {
    return DesktopModal(
      title: AppTranslations.of(context).text("generate_password"),
      body: _displaysBody(themeProvider),
      actions: [
        Container(
          margin: EdgeInsets.only(right: 8, bottom: 8),
          child: ChicTextButton(
            child: Text(AppTranslations.of(context).text("cancel")),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        Container(
          margin: EdgeInsets.only(right: 8, bottom: 8),
          child: ChicElevatedButton(
            child: Text(AppTranslations.of(context).text("done")),
            onPressed: () {
              Navigator.of(context).pop(_passwordController.text);
            },
          ),
        ),
      ],
    );
  }

  Widget _displaysMobile(ThemeProvider themeProvider) {
    var child = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: SingleChildScrollView(
        child: _displaysBody(themeProvider),
      ),
    );

    if (Platform.isIOS) {
      return CupertinoPageScaffold(
        backgroundColor: themeProvider.backgroundColor,
        navigationBar: _displaysIosAppbar(themeProvider),
        child: child,
      );
    } else {
      return Scaffold(
        backgroundColor: themeProvider.backgroundColor,
        appBar: _displaysAppbar(themeProvider),
        body: child,
      );
    }
  }

  ObstructingPreferredSizeWidget _displaysIosAppbar(
      ThemeProvider themeProvider) {
    return CupertinoNavigationBar(
      previousPageTitle: widget.previousPageTitle,
      backgroundColor: themeProvider.secondBackgroundColor,
      middle: Text(AppTranslations.of(context).text("generate_password")),
      trailing: CupertinoButton(
        padding: EdgeInsets.zero,
        child: Text(
          AppTranslations.of(context).text("done"),
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        onPressed: () {
          Navigator.of(context).pop(_passwordController.text);
        },
      ),
    );
  }

  PreferredSizeWidget? _displaysAppbar(ThemeProvider themeProvider) {
    return AppBar(
      backgroundColor: themeProvider.secondBackgroundColor,
      title: Text(AppTranslations.of(context).text("generate_password")),
      actions: [
        ChicTextButton(
          child: Text(AppTranslations.of(context).text("done")),
          onPressed: () {
            Navigator.of(context).pop(_passwordController.text);
          },
        ),
      ],
      bottom: _displayTabBar(themeProvider),
    );
  }

  Widget _displaysBody(ThemeProvider themeProvider) {
    String words = AppTranslations.of(context).text("words");
    String characters = AppTranslations.of(context).text("characters");
    int passwordSize = _passwordController.text.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Platform.isIOS ? _displaySegment(themeProvider) : SizedBox.shrink(),
        Container(
          margin: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ChicPlatform.isDesktop()
                  ? _displayTabBar(themeProvider)
                  : SizedBox.shrink(),
              ChicPlatform.isDesktop()
                  ? SizedBox(height: 16.0)
                  : SizedBox.shrink(),
              ChicTextField(
                controller: _passwordController,
                focus: _passwordFocusNode,
                desktopFocus: _desktopPasswordFocusNode,
                label: "",
                isReadOnly: true,
                hasStrengthIndicator: true,
                maxLines: null,
                suffix: Container(
                  margin: EdgeInsets.only(right: 8),
                  child: ChicIconButton(
                    icon: Platform.isIOS
                        ? CupertinoIcons.arrow_clockwise
                        : Icons.refresh,
                    color: themeProvider.primaryColor,
                    onPressed: () {
                      _passwordController.text = _generatePassword();
                      setState(() {});
                    },
                  ),
                ),
              ),
              SizedBox(height: 32.0),
              Text(
                _isGeneratingWords
                    ? "$words ($passwordSize $characters)"
                    : characters,
                style: TextStyle(
                  color: themeProvider.textColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 17,
                ),
              ),
              SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    child: Slider.adaptive(
                      value: _numberWords,
                      min: _minWords,
                      max: _maxWords,
                      divisions: _divisionWords,
                      activeColor: themeProvider.primaryColor,
                      onChanged: (double value) {
                        _numberWords = value;
                        _passwordController.text = _generatePassword();
                        setState(() {});
                      },
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 16),
                    child: Text(
                      "${_numberWords.ceil()}",
                      style: TextStyle(
                        color: themeProvider.textColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 17,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 32.0),
              Text(
                AppTranslations.of(context).text("settings"),
                style: TextStyle(
                  color: themeProvider.textColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 17,
                ),
              ),
              SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      AppTranslations.of(context).text("uppercase"),
                      style: TextStyle(
                        color: themeProvider.textColor,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  Switch.adaptive(
                    value: _hasUppercase,
                    activeColor: themeProvider.primaryColor,
                    onChanged: (bool value) {
                      _hasUppercase = value;
                      _passwordController.text = _generatePassword();
                      setState(() {});
                    },
                  ),
                ],
              ),
              SizedBox(height: 8.0),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      AppTranslations.of(context).text("digit"),
                      style: TextStyle(
                        color: themeProvider.textColor,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  Switch.adaptive(
                    value: _hasNumbers,
                    activeColor: themeProvider.primaryColor,
                    onChanged: (bool value) {
                      _hasNumbers = value;
                      _passwordController.text = _generatePassword();
                      setState(() {});
                    },
                  ),
                ],
              ),
              SizedBox(height: 8.0),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      AppTranslations.of(context).text("symbol"),
                      style: TextStyle(
                        color: themeProvider.textColor,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  Switch.adaptive(
                    value: _hasSpecialCharacters,
                    activeColor: themeProvider.primaryColor,
                    onChanged: (bool value) {
                      _hasSpecialCharacters = value;
                      _passwordController.text = _generatePassword();
                      setState(() {});
                    },
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              ChicTextField(
                controller: _languageController,
                focus: _languageFocusNode,
                desktopFocus: _desktopLanguageFocusNode,
                isReadOnly: true,
                label: AppTranslations.of(context).text("language"),
                onTap: _selectLanguage,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _displaySegment(ThemeProvider themeProvider) {
    return Container(
      width: double.maxFinite,
      color: themeProvider.secondBackgroundColor,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: CupertinoSlidingSegmentedControl<int>(
        groupValue: _segmentedControlIndex,
        onValueChanged: (index) {
          setState(() {
            _segmentedControlIndex = index;
          });

          _onTabBarItemTapped(index);
        },
        children: {
          0: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              AppTranslations.of(context).text("words"),
              style: TextStyle(color: themeProvider.textColor),
            ),
          ),
          1: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              AppTranslations.of(context).text("characters"),
              style: TextStyle(color: themeProvider.textColor),
            ),
          ),
        },
      ),
    );
  }

  PreferredSizeWidget _displayTabBar(ThemeProvider themeProvider) {
    return TabBar(
      controller: _tabController,
      indicatorColor: themeProvider.primaryColor,
      onTap: _onTabBarItemTapped,
      tabs: <Widget>[
        Tab(
          text: AppTranslations.of(context).text("words"),
        ),
        Tab(
          text: AppTranslations.of(context).text("characters"),
        ),
      ],
    );
  }

  _onTabBarItemTapped(int? index) {
    if (index == 0) {
      _isGeneratingWords = true;
      _numberWords = 4;
      _minWords = 1.0;
      _maxWords = 10.0;
      _divisionWords = 9;
    } else {
      _isGeneratingWords = false;
      _numberWords = 16;
      _minWords = 6.0;
      _maxWords = 50.0;
      _divisionWords = 43;
    }

    _passwordController.text = _generatePassword();
    setState(() {});
  }

  _selectLanguage() async {
    String? language = await ChicNavigator.push(
      context,
      SelectLanguageScreen(
        language: _locale?.languageCode,
      ),
      isModal: true,
    );

    if (language != null) {
      _locale = Locale(language);
      var index = Application.supportedLanguagesCodes.indexOf(language);
      _languageController.text = Application.supportedLanguages[index];
      _passwordController.text = _generatePassword();
      setState(() {});
    }
  }

  String _generatePassword() {
    if (_isGeneratingWords) {
      // Generating a password composed of words
      return Security.generatePasswordWithWords(
        _locale,
        _numberWords,
        _hasUppercase,
        _hasNumbers,
        _hasSpecialCharacters,
      );
    }

    // Generating a random password
    return _generateRandomPassword();
  }

  String _generateRandomPassword() {
    var newPassword = "";
    List<String> dictionary = [];

    dictionary.addAll(letters);
    dictionary.addAll(letters);

    if (_hasUppercase) {
      dictionary.addAll(uppercase);
    }

    if (_hasNumbers) {
      dictionary.addAll(numbers);
    }

    if (_hasSpecialCharacters) {
      dictionary.addAll(specialCharacters);
    }

    do {
      newPassword = "";

      for (var wordIndex = 0; wordIndex < _numberWords; wordIndex++) {
        var rng = new Random();
        newPassword += dictionary[rng.nextInt(dictionary.length - 1)];
      }
    } while (!_isPasswordGeneratedCorrect(newPassword));

    return newPassword;
  }

  bool _isPasswordGeneratedCorrect(String password) {
    var isPasswordCorrect = true;

    if (_hasUppercase && !password.contains(RegExp(r'[A-Z]'))) {
      isPasswordCorrect = false;
    }

    if (_hasNumbers && !password.contains(RegExp(r'[0-9]'))) {
      isPasswordCorrect = false;
    }

    if (_hasSpecialCharacters &&
        !specialCharacters
            .any((specialCharacter) => password.contains(specialCharacter))) {
      isPasswordCorrect = false;
    }

    return isPasswordCorrect;
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _languageController.dispose();

    _passwordFocusNode.dispose();
    _languageFocusNode.dispose();

    _desktopPasswordFocusNode.dispose();
    _desktopLanguageFocusNode.dispose();

    super.dispose();
  }
}
