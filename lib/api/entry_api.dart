import 'dart:convert';
import 'dart:io';

import 'package:chic_secret/api/auth_api.dart';
import 'package:chic_secret/model/api_error.dart';
import 'package:chic_secret/model/database/entry.dart';
import 'package:chic_secret/service/entry_service.dart';
import 'package:chic_secret/utils/constant.dart';
import 'package:chic_secret/utils/security.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

const String entries_route = "api/entries";

class EntryApi {
  static Future<void> sendEntries(List<Entry> entries) async {
    var client = http.Client();
    var accessToken = await Security.getAccessToken();

    if (accessToken == null || accessToken.isEmpty) {
      return;
    }

    var response = await client.post(
      Uri.parse("$url$entries_route"),
      headers: {HttpHeaders.authorizationHeader: "Bearer $accessToken"},
      body: json.encode({
        "entries": entries.map((v) => v.toJson()).toList(),
      }),
    );

    if (response.statusCode == 200) {
      return;
    } else if (response.statusCode == 401) {
      await AuthApi.refreshAccessToken();
      return await sendEntries(entries);
    } else {
      throw ApiError.fromJson(json.decode(response.body));
    }
  }

  static Future<void> retrieveEntries(DateTime? lastSync) async {
    var client = http.Client();
    var accessToken = await Security.getAccessToken();

    if (accessToken == null || accessToken.isEmpty) {
      return;
    }

    var dateFormatter = DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'");
    String entryUrl = "$url$entries_route";

    if (lastSync != null) {
      entryUrl += "?LastSynchro=${dateFormatter.format(lastSync)}";
    }

    var response = await client.get(
      Uri.parse(entryUrl),
      headers: {HttpHeaders.authorizationHeader: "Bearer $accessToken"},
    );

    if (response.statusCode == 200) {
      List<dynamic> dataList = json.decode(response.body)["entries"];

      for (var data in dataList) {
        var entry = Entry.fromJson(data);

        if (await EntryService.exists(entry)) {
          await EntryService.update(entry);
        } else {
          await EntryService.save(entry);
        }
      }

      return;
    } else if (response.statusCode == 401) {
      await AuthApi.refreshAccessToken();
      return await retrieveEntries(lastSync);
    } else {
      throw ApiError.fromJson(json.decode(response.body));
    }
  }
}
