import 'dart:collection';
import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:chic_secret/model/database/entry.dart';
import 'package:chic_secret/model/database/user.dart';
import 'package:chic_secret/model/database/vault.dart';
import 'package:chic_secret/service/entry_service.dart';
import 'package:chic_secret/utils/constant.dart';
import 'package:chic_secret/utils/shared_data.dart';
import 'package:chic_secret/utils/string_extension.dart';
import 'package:encrypt/encrypt.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuple/tuple.dart';

const String refreshTokenKey = "refreshTokenKey";
const String accessTokenKey = "accessTokenKey";
const String userKey = "userKey";
const String biometryKey = "biometryKey";

class Security {
  static String encrypt(String key, String message) {
    var encrypter = Encrypter(AES(Key.fromUtf8(encryptionKey)));
    var encrypted = encrypter.encrypt(message, iv: IV.fromUtf8(key));
    return encrypted.base64;
  }

  static String decrypt(String key, String message) {
    var encrypter = Encrypter(AES(Key.fromUtf8(encryptionKey)));
    var encrypted = Encrypted.fromBase64(message);
    return encrypter.decrypt(encrypted, iv: IV.fromUtf8(key));
  }

  static Future<Tuple3<List<Entry>, List<Entry>, List<Entry>>>
      retrievePasswordsSecurityInfo() async {
    List<Entry> weakPasswordEntries = [];
    List<Entry> oldEntries = [];
    List<Entry> duplicatedEntries = [];

    if (selectedVault != null) {
      var entries = await EntryService.getAllByVault(selectedVault!.id);

      for (var entry in entries.where((e) => e.deletedAt == null)) {
        if (entry.passwordSize != null && entry.passwordSize! <= 6) {
          weakPasswordEntries.add(entry);
        }

        var isOld =
            DateTime.now().difference(entry.updatedAt).inDays > (365 * 3) ||
                DateTime.now()
                        .difference(entry.hashUpdatedAt != null
                            ? entry.hashUpdatedAt!
                            : DateTime.now())
                        .inDays >
                    365;

        if (isOld) {
          oldEntries.add(entry);
        }

        var hasSamePassword = entries
            .where((e) => e.hash == entry.hash && e.id != entry.id)
            .isNotEmpty;

        if (hasSamePassword) {
          duplicatedEntries.add(entry);
        }
      }
    }

    return Tuple3(weakPasswordEntries, oldEntries, duplicatedEntries);
  }

  static addPasswordForBiometry(Vault vault, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonData = prefs.getString(biometryKey);

    if (jsonData == null || jsonData.isEmpty) {
      HashMap<String, String> biometryMap = HashMap();
      biometryMap[vault.id] = password;
      String biometryMapEncoded = json.encode(biometryMap);
      await prefs.setString(biometryKey, biometryMapEncoded);
    } else {
      var biometryMap = json.decode(jsonData);
      biometryMap[vault.id] = password;
      String biometryMapEncoded = json.encode(biometryMap);
      await prefs.setString(biometryKey, biometryMapEncoded);
    }
  }

  static removePasswordFromBiometry(Vault vault) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonData = prefs.getString(biometryKey);

    if (jsonData != null && jsonData.isNotEmpty) {
      var biometryMap = json.decode(jsonData);
      biometryMap.remove(vault.id);
      String biometryMapEncoded = json.encode(biometryMap);
      await prefs.setString(biometryKey, biometryMapEncoded);
    }
  }

  static Future<bool> isPasswordSavedForBiometry(Vault vault) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonData = prefs.getString(biometryKey);

    if (jsonData != null && jsonData.isNotEmpty) {
      var biometryMap = json.decode(jsonData);

      if (biometryMap[vault.id] != null) {
        return true;
      }
    }

    return false;
  }

  static Future<String?> getPasswordFromBiometry(Vault vault) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonData = prefs.getString(biometryKey);

    if (jsonData != null && jsonData.isNotEmpty) {
      var biometryMap = json.decode(jsonData);

      if (biometryMap[vault.id] != null) {
        return biometryMap[vault.id];
      }
    }

    return null;
  }

  static Future<User?> getCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userJSON = prefs.getString(userKey);

    if (userJSON != null && userJSON.isNotEmpty) {
      return User.fromJson(json.decode(userJSON));
    } else {
      return null;
    }
  }

  static setCurrentUser(User user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(userKey, json.encode(user.toJson()));
  }

  static Future<bool> isConnected() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? refreshToken = prefs.getString(refreshTokenKey);

    return refreshToken != null && refreshToken.isNotEmpty;
  }

  static Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<String?> getRefreshToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(refreshTokenKey);
  }

  static Future<void> setRefreshToken(String refreshToken) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(refreshTokenKey, refreshToken);
  }

  static Future<String?> getAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(accessTokenKey);
  }

  static Future<void> setAccessToken(String accessToken) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(accessTokenKey, accessToken);
  }

  static String generatePasswordWithWords(
    Locale? locale,
    double numberWords,
    bool hasUppercase,
    bool hasNumbers,
    bool hasSpecialCharacters,
  ) {
    var newPassword = "";

    for (var wordIndex = 0; wordIndex < numberWords; wordIndex++) {
      var rng = new Random();
      String randomWord = "";

      if (locale!.languageCode == "fr") {
        randomWord = wordsFrench[rng.nextInt(wordsFrench.length - 1)];
      } else if (locale.languageCode == "es") {
        randomWord = wordsSpanish[rng.nextInt(wordsSpanish.length - 1)];
      } else {
        randomWord = words[rng.nextInt(words.length - 1)];
      }

      if (hasUppercase) {
        var uppercaseLuck = rng.nextInt(10);

        if (uppercaseLuck >= 8) {
          randomWord = randomWord.capitalizeLast();
        } else if (uppercaseLuck >= 4) {
          randomWord = randomWord.capitalizeFirst();
        }
      }

      if (hasNumbers) {
        var numberLuck = rng.nextInt(10);

        if (numberLuck >= 6) {
          var randomNumber = numbers[rng.nextInt(numbers.length - 1)];
          randomWord += randomNumber;
        }
      }

      if (hasSpecialCharacters) {
        var specialCharacterLuck = rng.nextInt(10);

        if (specialCharacterLuck >= 7) {
          var randomSpecialCharacter =
              specialCharacters[rng.nextInt(specialCharacters.length - 1)];
          randomWord += randomSpecialCharacter;
        }
      }

      if (wordIndex != numberWords.ceil() - 1) {
        randomWord += "_";
      }

      newPassword += randomWord;
    }

    if (hasUppercase && !newPassword.contains(RegExp(r'[A-Z]'))) {
      newPassword = newPassword.capitalizeFirst();
    }

    if (hasNumbers && !newPassword.contains(RegExp(r'[0-9]'))) {
      var rng = new Random();
      var randomNumber = numbers[rng.nextInt(numbers.length - 1)];
      newPassword += randomNumber;
    }

    if (hasSpecialCharacters &&
        !specialCharacters.any(
            (specialCharacter) => newPassword.contains(specialCharacter))) {
      var rng = new Random();
      var randomSpecialCharacter =
          specialCharacters[rng.nextInt(specialCharacters.length - 1)];
      newPassword += randomSpecialCharacter;
    }

    return newPassword;
  }
}
