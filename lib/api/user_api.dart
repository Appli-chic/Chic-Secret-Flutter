import 'dart:convert';
import 'dart:io';

import 'package:chic_secret/model/api_error.dart';
import 'package:chic_secret/model/database/user.dart';
import 'package:chic_secret/utils/constant.dart';
import 'package:chic_secret/utils/security.dart';
import 'package:http/http.dart' as http;

const String getUser = "api/user";

class UserApi {

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
