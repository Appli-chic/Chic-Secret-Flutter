import 'dart:convert';

import 'package:chic_secret/model/api_error.dart';
import 'package:chic_secret/utils/constant.dart';
import 'package:chic_secret/utils/security.dart';
import 'package:http/http.dart' as http;

const String authAskCodeLogin = "api/auth/ask_code";
const String authLogin = "api/auth/login";
const String authRefresh = "api/auth/refresh";

class AuthApi {
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
