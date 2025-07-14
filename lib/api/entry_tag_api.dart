import 'dart:convert';
import 'dart:io';

import 'package:chic_secret/api/auth_api.dart';
import 'package:chic_secret/model/api_error.dart';
import 'package:chic_secret/model/database/entry_tag.dart';
import 'package:chic_secret/service/entry_tag_service.dart';
import 'package:chic_secret/utils/constant.dart';
import 'package:chic_secret/utils/security.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

const String entry_tags_route = "api/entry-tags";

class EntryTagApi {
  static Future<void> sendEntryTags(List<EntryTag> entryTags) async {
    var client = http.Client();
    var accessToken = await Security.getAccessToken();

    if (accessToken == null || accessToken.isEmpty) {
      return;
    }

    var response = await client.post(
      Uri.parse("$url$entry_tags_route"),
      headers: {HttpHeaders.authorizationHeader: "Bearer $accessToken"},
      body: json.encode({
        "EntryTags": entryTags.map((v) => v.toJson()).toList(),
      }),
    );

    if (response.statusCode == 200) {
      return;
    } else if (response.statusCode == 401) {
      await AuthApi.refreshAccessToken();
      return await sendEntryTags(entryTags);
    } else {
      throw ApiError.fromJson(json.decode(response.body));
    }
  }

  static Future<void> retrieveEntryTags(DateTime? lastSync) async {
    var client = http.Client();
    var accessToken = await Security.getAccessToken();

    if (accessToken == null || accessToken.isEmpty) {
      return;
    }

    var dateFormatter = DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'");
    String entryTagUrl = "$url$entry_tags_route";

    if (lastSync != null) {
      entryTagUrl += "?LastSynchro=${dateFormatter.format(lastSync)}";
    }

    var response = await client.get(
      Uri.parse(entryTagUrl),
      headers: {HttpHeaders.authorizationHeader: "Bearer $accessToken"},
    );

    if (response.statusCode == 200) {
      List<dynamic> dataList = json.decode(response.body)["entry_tags"];

      for (var data in dataList) {
        var entryTag = EntryTag.fromJson(data);

        if (await EntryTagService.exists(entryTag)) {
          await EntryTagService.update(entryTag);
        } else {
          await EntryTagService.save(entryTag);
        }
      }

      return;
    } else if (response.statusCode == 401) {
      await AuthApi.refreshAccessToken();
      return await retrieveEntryTags(lastSync);
    } else {
      throw ApiError.fromJson(json.decode(response.body));
    }
  }
}
