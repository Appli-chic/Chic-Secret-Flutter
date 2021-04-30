import 'dart:convert';

import 'package:chic_secret/model/database/user.dart';
import 'package:chic_secret/utils/constant.dart';
import 'package:encrypt/encrypt.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String refreshTokenKey = "refreshTokenKey";
const String accessTokenKey = "accessTokenKey";
const String userKey = "userKey";

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
