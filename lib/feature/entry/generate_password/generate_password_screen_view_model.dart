import 'dart:math';

import 'package:chic_secret/localization/application.dart';
import 'package:chic_secret/utils/constant.dart';
import 'package:chic_secret/utils/rich_text_editing_controller.dart';
import 'package:chic_secret/utils/security.dart';
import 'package:flutter/material.dart';

class GeneratePasswordScreenViewModel with ChangeNotifier {
  Locale? locale;
  late TabController tabController;
  final passwordController = RichTextEditingController();
  final languageController = TextEditingController();

  var isGeneratingWords = true;
  int? segmentedControlIndex = 0;

  var hasUppercase = true;
  var hasNumbers = true;
  var hasSpecialCharacters = true;

  var numberWords = defaultPasswordWordNumber;
  var minWords = 1.0;
  var maxWords = 10.0;
  var divisionWords = 9;

  GeneratePasswordScreenViewModel(
    BuildContext context,
    TabController tabController,
  ) {
    this.tabController = tabController;
    locale = Localizations.localeOf(context);
    passwordController.text = generatePassword();
    languageController.text =
        Application.getSupportedLanguageFromCode(locale!.languageCode);
  }

  onGeneratePassword() {
    passwordController.text = generatePassword();
  }

  onUppercaseSwitchChanged(bool value) {
    hasUppercase = value;
    passwordController.text = generatePassword();
    notifyListeners();
  }

  onDigitSwitchChanged(bool value) {
    hasNumbers = value;
    passwordController.text = generatePassword();
    notifyListeners();
  }

  onSpecialCharacterSwitchChanged(bool value) {
    hasSpecialCharacters = value;
    passwordController.text = generatePassword();
    notifyListeners();
  }

  onSegmentedControlChanged(int? index) {
    segmentedControlIndex = index;
    onTabBarItemTapped(index);
    notifyListeners();
  }

  onTabBarItemTapped(int? index) {
    if (index == 0) {
      isGeneratingWords = true;
      numberWords = 4;
      minWords = 1.0;
      maxWords = 10.0;
      divisionWords = 9;
    } else {
      isGeneratingWords = false;
      numberWords = 16;
      minWords = 6.0;
      maxWords = 50.0;
      divisionWords = 43;
    }

    passwordController.text = generatePassword();
    notifyListeners();
  }

  setLanguage(String language) async {
    locale = Locale(language);
    var index = Application.supportedLanguagesCodes.indexOf(language);
    languageController.text = Application.supportedLanguages[index];
    passwordController.text = generatePassword();
    notifyListeners();
  }

  onAmountWordsChanged(double value) {
    numberWords = value;
    passwordController.text = generatePassword();
    notifyListeners();
  }

  String generatePassword() {
    if (isGeneratingWords) {
      // Generating a password composed of words
      return Security.generatePasswordWithWords(
        locale,
        numberWords,
        hasUppercase,
        hasNumbers,
        hasSpecialCharacters,
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

    if (hasUppercase) {
      dictionary.addAll(uppercase);
    }

    if (hasNumbers) {
      dictionary.addAll(numbers);
    }

    if (hasSpecialCharacters) {
      dictionary.addAll(specialCharacters);
    }

    do {
      newPassword = "";

      for (var wordIndex = 0; wordIndex < numberWords; wordIndex++) {
        var rng = new Random();
        newPassword += dictionary[rng.nextInt(dictionary.length - 1)];
      }
    } while (!_isPasswordGeneratedCorrect(newPassword));

    return newPassword;
  }

  bool _isPasswordGeneratedCorrect(String password) {
    var isPasswordCorrect = true;

    if (hasUppercase && !password.contains(RegExp(r'[A-Z]'))) {
      isPasswordCorrect = false;
    }

    if (hasNumbers && !password.contains(RegExp(r'[0-9]'))) {
      isPasswordCorrect = false;
    }

    if (hasSpecialCharacters &&
        !specialCharacters
            .any((specialCharacter) => password.contains(specialCharacter))) {
      isPasswordCorrect = false;
    }

    return isPasswordCorrect;
  }
}
