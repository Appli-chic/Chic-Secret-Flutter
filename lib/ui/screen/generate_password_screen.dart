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
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chic_secret/utils/string_extension.dart';

class GeneratePasswordScreen extends StatefulWidget {
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

  var _hasUppercase = true;
  var _hasNumbers = true;
  var _hasSpecialCharacters = true;

  // if _isGeneratingWords is false then it's the number of characters
  var _numberWords = 4.0;
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

  /// Displays the screen in a modal for the desktop version
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

  /// Displays the Mobile scaffold
  Widget _displaysMobile(ThemeProvider themeProvider) {
    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(
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
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: SingleChildScrollView(
          child: _displaysBody(themeProvider),
        ),
      ),
    );
  }

  /// Displays a unified body for Mobile and Desktop
  Widget _displaysBody(ThemeProvider themeProvider) {
    return Container(
      margin: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ChicPlatform.isDesktop()
              ? _displayTabBar(themeProvider)
              : SizedBox.shrink(),
          ChicPlatform.isDesktop() ? SizedBox(height: 16.0) : SizedBox.shrink(),
          ChicTextField(
            controller: _passwordController,
            focus: _passwordFocusNode,
            desktopFocus: _desktopPasswordFocusNode,
            hint: "",
            isReadOnly: true,
            hasStrengthIndicator: true,
            maxLines: null,
            suffix: Container(
              margin: EdgeInsets.only(right: 8),
              child: ChicIconButton(
                icon: Icons.refresh,
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
                ? AppTranslations.of(context).text("words")
                : AppTranslations.of(context).text("characters"),
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
            hint: AppTranslations.of(context).text("language"),
            onTap: _selectLanguage,
          ),
        ],
      ),
    );
  }

  /// Displays a tabBar to select the type of password generation
  /// Word based password or random number/characters password
  PreferredSizeWidget _displayTabBar(ThemeProvider themeProvider) {
    return TabBar(
      controller: _tabController,
      indicatorColor: themeProvider.primaryColor,
      onTap: (int index) {
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
      },
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

  /// Select the language to generate a new password from a range of languages supported
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

  /// Called to generate a new password
  String _generatePassword() {
    if (_isGeneratingWords) {
      // Generating a password composed of words
      return _generatePasswordWithWords();
    }

    // Generating a random password
    return _generateRandomPassword();
  }

  /// Generates a password made of random numbers/characters
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

    for (var wordIndex = 0; wordIndex < _numberWords; wordIndex++) {
      var rng = new Random();
      newPassword += dictionary[rng.nextInt(dictionary.length - 1)];
    }

    return newPassword;
  }

  /// Generates a password based of words
  String _generatePasswordWithWords() {
    var newPassword = "";

    for (var wordIndex = 0; wordIndex < _numberWords; wordIndex++) {
      var rng = new Random();
      String randomWord = "";

      if (_locale!.languageCode == "fr") {
        // French
        randomWord = wordsFrench[rng.nextInt(wordsFrench.length - 1)];
      } else if (_locale!.languageCode == "es") {
        // French
        randomWord = wordsSpanish[rng.nextInt(wordsSpanish.length - 1)];
      } else {
        // English by default
        randomWord = words[rng.nextInt(words.length - 1)];
      }

      // Randomly add an uppercase
      if (_hasUppercase) {
        var uppercaseLuck = rng.nextInt(10);

        if (uppercaseLuck >= 8) {
          randomWord = randomWord.capitalizeLast();
        } else if (uppercaseLuck >= 4) {
          randomWord = randomWord.capitalizeFirst();
        }
      }

      // Randomly add a number
      if (_hasNumbers) {
        var numberLuck = rng.nextInt(10);

        if (numberLuck >= 8) {
          var randomNumber = numbers[rng.nextInt(numbers.length - 1)];
          randomWord += randomNumber;
        }
      }

      // Randomly add a special character
      if (_hasSpecialCharacters) {
        var specialCharacterLuck = rng.nextInt(10);

        if (specialCharacterLuck >= 6) {
          var randomSpecialCharacter =
              specialCharacters[rng.nextInt(specialCharacters.length - 1)];
          randomWord += randomSpecialCharacter;
        }
      }

      // Add space between words
      if (wordIndex != _numberWords.ceil() - 1) {
        randomWord += "_";
      }

      newPassword += randomWord;
    }

    return newPassword;
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
