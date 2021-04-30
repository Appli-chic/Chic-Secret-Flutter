import 'dart:convert';
import 'dart:io';
import 'package:chic_secret/service/vault_service.dart';
import 'package:intl/intl.dart';

import 'package:chic_secret/api/auth_api.dart';
import 'package:chic_secret/model/api_error.dart';
import 'package:chic_secret/model/database/vault.dart';
import 'package:chic_secret/utils/constant.dart';
import 'package:chic_secret/utils/security.dart';
import 'package:http/http.dart' as http;

const String vaults_route = "api/vaults";

class VaultApi {
  /// Send the vaults to synchronize to the server
  static Future<void> sendVaults(List<Vault> vaults) async {
    var client = http.Client();
    var accessToken = await Security.getAccessToken();

    var response = await client.post(
      Uri.parse("$url$vaults_route"),
      headers: {HttpHeaders.authorizationHeader: "Bearer $accessToken"},
      body: json.encode({
        "vaults": vaults.map((v) => v.toJson()).toList(),
      }),
    );

    if (response.statusCode == 200) {
      return;
    } else if (response.statusCode == 401) {
      await AuthApi.refreshAccessToken();
      return await sendVaults(vaults);
    } else {
      throw ApiError.fromJson(json.decode(response.body));
    }
  }

  /// Retrieve all the vaults that changed
  static Future<void> retrieveVaults(DateTime? lastSync) async {
    var client = http.Client();
    var accessToken = await Security.getAccessToken();
    var dateFormatter = DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'");
    String vaultUrl = "$url$vaults_route";

    if (lastSync != null) {
      vaultUrl += "?LastSynchro=${dateFormatter.format(lastSync)}";
    }

    var response = await client.get(
        Uri.parse("$vaultUrl"),
      headers: {HttpHeaders.authorizationHeader: "Bearer $accessToken"},
    );

    if (response.statusCode == 200) {
      List<dynamic> dataList = json.decode(response.body)["vaults"];

      for (var data in dataList) {
        var vault = Vault.fromJson(data);
        await VaultService.save(vault);
      }

      return;
    } else if (response.statusCode == 401) {
      await AuthApi.refreshAccessToken();
      return await retrieveVaults(lastSync);
    } else {
      throw ApiError.fromJson(json.decode(response.body));
    }
  }
}
