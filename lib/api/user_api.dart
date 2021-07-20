import 'dart:convert';
import 'dart:io';

import 'package:chic_secret/model/api_error.dart';
import 'package:chic_secret/model/database/user.dart';
import 'package:chic_secret/utils/constant.dart';
import 'package:chic_secret/utils/security.dart';
import 'package:http/http.dart' as http;

import 'auth_api.dart';

const String getUser = "api/user";

class UserApi {
  /// Send a user to synchronize to the server
  static Future<void> sendUser(User user) async {
    var client = http.Client();
    var accessToken = await Security.getAccessToken();

    if (accessToken == null || accessToken.isEmpty) {
      return;
    }

    var response = await client.post(
      Uri.parse("$url$getUser"),
      headers: {HttpHeaders.authorizationHeader: "Bearer $accessToken"},
      body: json.encode({
        "user": user.toJson(),
      }),
    );

    if (response.statusCode == 200) {
      return;
    } else if (response.statusCode == 401) {
      await AuthApi.refreshAccessToken();
      return await sendUser(user);
    } else {
      throw ApiError.fromJson(json.decode(response.body));
    }
  }

  /// Get the current user logged in
  static Future<User> getCurrentUser() async {
    var client = http.Client();
    var accessToken = await Security.getAccessToken();

    var response = await client.get(
      Uri.parse("$url$getUser"),
      headers: {HttpHeaders.authorizationHeader: "Bearer $accessToken"},
    );

    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body)["user"]);
    } else {
      throw ApiError.fromJson(json.decode(response.body));
    }
  }
}
