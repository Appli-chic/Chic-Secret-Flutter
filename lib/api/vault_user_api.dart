import 'dart:convert';
import 'dart:io';

import 'package:chic_secret/api/auth_api.dart';
import 'package:chic_secret/model/api_error.dart';
import 'package:chic_secret/model/database/vault_user.dart';
import 'package:chic_secret/service/vault_user_service.dart';
import 'package:chic_secret/utils/constant.dart';
import 'package:chic_secret/utils/security.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

const String vault_users_route = "api/vault-users";

class VaultUserApi {
  /// Send the vault users to synchronize to the server
  static Future<void> sendVaultUsers(List<VaultUser> vaultUsers) async {
    var client = http.Client();
    var accessToken = await Security.getAccessToken();

    if (accessToken == null || accessToken.isEmpty) {
      return;
    }

    var response = await client.post(
      Uri.parse("$url$vault_users_route"),
      headers: {HttpHeaders.authorizationHeader: "Bearer $accessToken"},
      body: json.encode({
        "VaultUsers": vaultUsers.map((v) => v.toJson()).toList(),
      }),
    );

    if (response.statusCode == 200) {
      return;
    } else if (response.statusCode == 401) {
      await AuthApi.refreshAccessToken();
      return await sendVaultUsers(vaultUsers);
    } else {
      throw ApiError.fromJson(json.decode(response.body));
    }
  }

  /// Retrieve all the vault users that changed
  static Future<void> retrieveVaultUsers(DateTime? lastSync) async {
    var client = http.Client();
    var accessToken = await Security.getAccessToken();

    if (accessToken == null || accessToken.isEmpty) {
      return;
    }

    var dateFormatter = DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'");
    String entryTagUrl = "$url$vault_users_route";

    if (lastSync != null) {
      entryTagUrl += "?LastSynchro=${dateFormatter.format(lastSync)}";
    }

    var response = await client.get(
      Uri.parse(entryTagUrl),
      headers: {HttpHeaders.authorizationHeader: "Bearer $accessToken"},
    );

    if (response.statusCode == 200) {
      List<dynamic> dataList = json.decode(response.body)["vault_users"];

      for (var data in dataList) {
        var vaultUser = VaultUser.fromJson(data);

        if (await VaultUserService.exists(vaultUser)) {
          await VaultUserService.update(vaultUser);
        } else {
          await VaultUserService.save(vaultUser);
        }
      }

      return;
    } else if (response.statusCode == 401) {
      await AuthApi.refreshAccessToken();
      return await retrieveVaultUsers(lastSync);
    } else {
      throw ApiError.fromJson(json.decode(response.body));
    }
  }
}
