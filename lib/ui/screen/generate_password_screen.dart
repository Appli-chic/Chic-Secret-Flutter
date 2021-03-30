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

  @override
  void initState() {
    _nameController.text = _generatePassword(5, true, true, true);
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
          ),
        ],
      ),
    );
  }

  String _generatePassword(int nbWords, bool hasUppercase, bool hasNumbers,
      bool hasSpecialCharacters) {
    if (_isGeneratingWords) {
      // Generating a password composed of words
      var newPassword = "";

      for (var wordIndex = 0; wordIndex < nbWords; wordIndex++) {
        var rng = new Random();
        var randomWord = words[rng.nextInt(words.length - 1)];

        // Randomly add an uppercase
        if (hasUppercase) {
          var uppercaseLuck = rng.nextInt(10);

          if (uppercaseLuck >= 8) {
            randomWord.capitalizeLast();
          } else if (uppercaseLuck >= 4) {
            randomWord.capitalizeFirst();
          }
        }

        // Randomly add a number
        if (hasNumbers) {
          var numberLuck = rng.nextInt(10);

          if (numberLuck >= 8) {
            var randomNumber = numbers[rng.nextInt(numbers.length - 1)];
            randomWord += randomNumber;
          }
        }

        // Randomly add a special character
        if (hasSpecialCharacters) {
          var specialCharacterLuck = rng.nextInt(10);

          if (specialCharacterLuck >= 6) {
            var randomSpecialCharacter =
            specialCharacters[rng.nextInt(specialCharacters.length - 1)];
            randomWord += randomSpecialCharacter;
          }
        }

        // Add space between words
        if (wordIndex != nbWords - 1) {
          randomWord += " ";
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
