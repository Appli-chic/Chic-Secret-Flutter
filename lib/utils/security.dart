import 'dart:collection';
import 'dart:convert';

import 'package:chic_secret/model/database/entry.dart';
import 'package:chic_secret/model/database/user.dart';
import 'package:chic_secret/model/database/vault.dart';
import 'package:chic_secret/service/entry_service.dart';
import 'package:chic_secret/ui/screen/vaults_screen.dart';
import 'package:chic_secret/utils/constant.dart';
import 'package:encrypt/encrypt.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuple/tuple.dart';

const String refreshTokenKey = "refreshTokenKey";
const String accessTokenKey = "accessTokenKey";
const String userKey = "userKey";
const String biometryKey = "biometryKey";

class Security {
  /// Encrypt a message from a key password
  static String encrypt(String key, String message) {
    var encrypter = Encrypter(AES(Key.fromUtf8(encryptionKey)));
    var encrypted = encrypter.encrypt(message, iv: IV.fromUtf8(key));
    return encrypted.base64;
  }

  /// Decrypt a message from a key password
  static String decrypt(String key, String message) {
    var encrypter = Encrypter(AES(Key.fromUtf8(encryptionKey)));
    var encrypted = Encrypted.fromBase64(message);
    return encrypter.decrypt(encrypted, iv: IV.fromUtf8(key));
  }

  /// Retrieve the weak passwords, old passwords and duplicated passwords
  static Future<Tuple3<List<Entry>, List<Entry>, List<Entry>>>
      retrievePasswordsSecurityInfo() async {
    List<Entry> weakPasswordEntries = [];
    List<Entry> oldEntries = [];
    List<Entry> duplicatedEntries = [];

    if (selectedVault != null) {
      var entries = await EntryService.getAllByVault(selectedVault!.id);

      for (var entry in entries.where((e) => e.deletedAt == null)) {
        // Get weak passwords
        if (entry.passwordSize != null && entry.passwordSize! <= 6) {
          weakPasswordEntries.add(entry);
        }

        // Get old entries
        var isOld = DateTime.now().difference(entry.updatedAt).inDays > 365 ||
            DateTime.now()
                    .difference(entry.hashUpdatedAt != null
                        ? entry.hashUpdatedAt!
                        : DateTime.now())
                    .inDays >
                365;

        if (isOld) {
          oldEntries.add(entry);
        }

        // Get duplicated entries
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

  /// Add the password in the shared preferences to unlock the vault
  /// automatically with biometry
  static addPasswordForBiometry(Vault vault, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonData = prefs.getString(biometryKey);

    if (jsonData == null || jsonData.isEmpty) {
      // Add the first biometry password
      HashMap<String, String> biometryMap = HashMap();
      biometryMap[vault.id] = password;
      String biometryMapEncoded = json.encode(biometryMap);
      await prefs.setString(biometryKey, biometryMapEncoded);
    } else {
      // Add a biometry password in an existing Map
      var biometryMap = json.decode(jsonData);
      biometryMap[vault.id] = password;
      String biometryMapEncoded = json.encode(biometryMap);
      await prefs.setString(biometryKey, biometryMapEncoded);
    }
  }

  /// Remove a password from the map of passwords for biometry
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

  /// Retrieve the password saved if it exists for this [vault]
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

  /// Retrieve the password stored in the shared preference linked to this vault
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

  /// Get the current user
  static Future<User?> getCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userJSON = prefs.getString(userKey);

    if (userJSON != null && userJSON.isNotEmpty) {
      return User.fromJson(json.decode(userJSON));
    } else {
      return null;
    }
  }

  /// Save the current user
  static setCurrentUser(User user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(userKey, json.encode(user.toJson()));
  }

  /// Is the user connected
  static Future<bool> isConnected() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? refreshToken = prefs.getString(refreshTokenKey);

    return refreshToken != null && refreshToken.isNotEmpty;
  }

  /// Logout the user
  static Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  /// Get the refresh token from the preferences
  static Future<String?> getRefreshToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(refreshTokenKey);
  }

  /// Set the refresh token in the preferences
  static Future<void> setRefreshToken(String refreshToken) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(refreshTokenKey, refreshToken);
  }

  /// Get the access token from the preferences
  static Future<String?> getAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(accessTokenKey);
  }

  /// Set the access token in the preferences
  static Future<void> setAccessToken(String accessToken) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(accessTokenKey, accessToken);
  }
}
