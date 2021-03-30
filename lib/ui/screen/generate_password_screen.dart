import 'dart:math';

import 'package:chic_secret/localization/app_translations.dart';
import 'package:chic_secret/provider/theme_provider.dart';
import 'package:chic_secret/ui/component/common/chic_elevated_button.dart';
import 'package:chic_secret/ui/component/common/chic_text_button.dart';
import 'package:chic_secret/ui/component/common/chic_text_field.dart';
import 'package:chic_secret/ui/component/common/desktop_modal.dart';
import 'package:chic_secret/utils/chic_platform.dart';
import 'package:chic_secret/utils/constant.dart';
import 'package:chic_secret/utils/string_extension.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GeneratePasswordScreen extends StatefulWidget {
  @override
  _GeneratePasswordScreenState createState() => _GeneratePasswordScreenState();
}

class _GeneratePasswordScreenState extends State<GeneratePasswordScreen> {
  final _nameController = TextEditingController();
  var _nameFocusNode = FocusNode();
  var _desktopNameFocusNode = FocusNode();

  var _isGeneratingWords = true;
  var _numberWords = 4.0;
  var _hasUppercase = true;
  var _hasNumbers = true;
  var _hasSpecialCharacters = true;

  @override
  void initState() {
    _nameController.text = _generatePassword();
    super.initState();
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
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  Widget _displaysMobile(ThemeProvider themeProvider) {
    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(
        backgroundColor: themeProvider.secondBackgroundColor,
        brightness: themeProvider.getBrightness(),
        title: Text(AppTranslations.of(context).text("generate_password")),
        actions: [
          ChicTextButton(
            child: Text(AppTranslations.of(context).text("done").toUpperCase()),
            onPressed: () {},
          ),
        ],
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

  Widget _displaysBody(ThemeProvider themeProvider) {
    return Container(
      margin: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ChicTextField(
            controller: _nameController,
            focus: _nameFocusNode,
            desktopFocus: _desktopNameFocusNode,
            hint: "",
            isReadOnly: true,
            hasStrengthIndicator: true,
            maxLines: null,
          ),
          SizedBox(height: 32.0),
          Text(
            AppTranslations.of(context).text("words"),
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
                  min: 1.0,
                  max: 10.0,
                  divisions: 9,
                  activeColor: themeProvider.primaryColor,
                  onChanged: (double value) {
                    _numberWords = value;
                    _nameController.text = _generatePassword();
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
                  _nameController.text = _generatePassword();
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
                  _nameController.text = _generatePassword();
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
                  _nameController.text = _generatePassword();
                  setState(() {});
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _generatePassword() {
    if (_isGeneratingWords) {
      // Generating a password composed of words
      var newPassword = "";

      for (var wordIndex = 0; wordIndex < _numberWords; wordIndex++) {
        var rng = new Random();
        var randomWord = words[rng.nextInt(words.length - 1)];

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

    return "";
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode.dispose();
    _desktopNameFocusNode.dispose();

    super.dispose();
  }
}
