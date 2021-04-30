import 'dart:convert';

import 'package:chic_secret/model/api_error.dart';
import 'package:chic_secret/utils/constant.dart';
import 'package:chic_secret/utils/security.dart';
import 'package:http/http.dart' as http;

const String authAskCodeLogin = "api/auth/ask_code";
const String authLogin = "api/auth/login";
const String authRefresh = "api/auth/refresh";

class AuthApi {
  /// Ask the server to send a code to the email
  static Future<void> askCodeToLogin(String email) async {
    var client = http.Client();

    var response = await client.post(
      Uri.parse("$url$authAskCodeLogin"),
      body: json.encode({
        "email": email,
      }),
    );

    if (response.statusCode == 200) {
      return;
    } else {
      throw ApiError.fromJson(json.decode(response.body));
    }
  }

  /// Login with the [email] and corresponding [code]
  static Future<void> login(String email, String code) async {
    var client = http.Client();

    var response = await client.post(
      Uri.parse("$url$authLogin"),
      body: json.encode({
        "email": email,
        "token": int.parse(code),
      }),
    );

    if (response.statusCode == 200) {
      var responseData = json.decode(response.body);
      await Security.setRefreshToken(responseData["refreshToken"]);
      await Security.setAccessToken(responseData["accessToken"]);

      return;
    } else {
      throw ApiError.fromJson(json.decode(response.body));
    }
  }

  /// Send an access token from our refresh token
  static Future<void> refreshAccessToken() async {
    var client = http.Client();
    var refreshToken = await Security.getRefreshToken();

    var response = await client.post(
      Uri.parse("$url$authRefresh"),
      body: json.encode({
        "refreshToken": refreshToken,
      }),
    );

    if (response.statusCode == 200) {
      var responseData = json.decode(response.body);
      await Security.setAccessToken(responseData["accessToken"]);

      return;
    } else {
      throw ApiError.fromJson(json.decode(response.body));
    }
  }
}
