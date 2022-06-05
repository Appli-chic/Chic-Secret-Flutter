import 'dart:convert';
import 'dart:io';
import 'package:chic_secret/service/user_service.dart';
import 'package:intl/intl.dart';

import 'package:chic_secret/model/api_error.dart';
import 'package:chic_secret/model/database/user.dart';
import 'package:chic_secret/utils/constant.dart';
import 'package:chic_secret/utils/security.dart';
import 'package:http/http.dart' as http;

import 'auth_api.dart';

const String getUserRoute = "api/user";
const String deleteUserRoute = "api/user/delete";
const String getUsersRoute = "api/users";

class UserApi {
  static Future<void> sendUser(User user) async {
    var client = http.Client();
    var accessToken = await Security.getAccessToken();

    if (accessToken == null || accessToken.isEmpty) {
      return;
    }

    var response = await client.post(
      Uri.parse("$url$getUserRoute"),
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

  static Future<User?> getCurrentUser() async {
    var client = http.Client();
    var accessToken = await Security.getAccessToken();

    if (accessToken == null || accessToken.isEmpty) {
      return null;
    }

    var response = await client.get(
      Uri.parse("$url$getUserRoute"),
      headers: {HttpHeaders.authorizationHeader: "Bearer $accessToken"},
    );

    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body)["user"]);
    } else {
      throw ApiError.fromJson(json.decode(response.body));
    }
  }

  static Future<void> deleteUser() async {
    var client = http.Client();
    var accessToken = await Security.getAccessToken();

    if (accessToken == null || accessToken.isEmpty) {
      return null;
    }

    var response = await client.get(
      Uri.parse("$url$deleteUserRoute"),
      headers: {HttpHeaders.authorizationHeader: "Bearer $accessToken"},
    );

    if (response.statusCode == 200) {
      return;
    } else if (response.statusCode == 401) {
      await AuthApi.refreshAccessToken();
      return await deleteUser();
    }  else {
      throw ApiError.fromJson(json.decode(response.body));
    }
  }

  static Future<User?> getUserByEmail(String email) async {
    var client = http.Client();
    var accessToken = await Security.getAccessToken();

    if (accessToken == null || accessToken.isEmpty) {
      return null;
    }

    var response = await client.get(
      Uri.parse("$url$getUserRoute/$email"),
      headers: {HttpHeaders.authorizationHeader: "Bearer $accessToken"},
    );

    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body)["user"]);
    } else if (response.statusCode == 401) {
      await AuthApi.refreshAccessToken();
      return await getUserByEmail(email);
    } else {
      throw ApiError.fromJson(json.decode(response.body));
    }
  }

  static Future<void> retrieveUsers(DateTime? lastSync) async {
    var client = http.Client();
    var accessToken = await Security.getAccessToken();

    if (accessToken == null || accessToken.isEmpty) {
      return;
    }

    var dateFormatter = DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'");
    String vaultUrl = "$url$getUsersRoute";

    if (lastSync != null) {
      vaultUrl += "?LastSynchro=${dateFormatter.format(lastSync)}";
    }

    var response = await client.get(
      Uri.parse(vaultUrl),
      headers: {HttpHeaders.authorizationHeader: "Bearer $accessToken"},
    );

    if (response.statusCode == 200) {
      List<dynamic> dataList = json.decode(response.body)["users"];

      for (var data in dataList) {
        var user = User.fromJson(data);

        if (await UserService.exists(user.id)) {
          await UserService.update(user);
        } else {
          await UserService.save(user);
        }
      }

      return;
    } else if (response.statusCode == 401) {
      await AuthApi.refreshAccessToken();
      return await retrieveUsers(lastSync);
    } else {
      throw ApiError.fromJson(json.decode(response.body));
    }
  }
}
