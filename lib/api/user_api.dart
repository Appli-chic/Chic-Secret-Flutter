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

const String getUser = "api/user";
const String getUsers = "api/users";

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

  /// Retrieve all the users that changed
  static Future<void> retrieveUsers(DateTime? lastSync) async {
    var client = http.Client();
    var accessToken = await Security.getAccessToken();

    if (accessToken == null || accessToken.isEmpty) {
      return;
    }

    var dateFormatter = DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'");
    String vaultUrl = "$url$getUsers";

    if (lastSync != null) {
      vaultUrl += "?LastSynchro=${dateFormatter.format(lastSync)}";
    }

    var response = await client.get(
      Uri.parse(vaultUrl),
      headers: {HttpHeaders.authorizationHeader: "Bearer $accessToken"},
    );

    if (response.statusCode == 200) {
      List<dynamic> dataList = json.decode(response.body)["vaults"];

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
