import 'dart:convert';
import 'dart:io';

import 'package:chic_secret/api/auth_api.dart';
import 'package:chic_secret/model/api_error.dart';
import 'package:chic_secret/model/database/tag.dart';
import 'package:chic_secret/service/tag_service.dart';
import 'package:chic_secret/utils/constant.dart';
import 'package:chic_secret/utils/security.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

const String tags_route = "api/tags";

class TagApi {
  /// Send the tags to synchronize to the server
  static Future<void> sendTags(List<Tag> tags) async {
    var client = http.Client();
    var accessToken = await Security.getAccessToken();

    if (accessToken == null || accessToken.isEmpty) {
      return;
    }

    var response = await client.post(
      Uri.parse("$url$tags_route"),
      headers: {HttpHeaders.authorizationHeader: "Bearer $accessToken"},
      body: json.encode({
        "tags": tags.map((v) => v.toJson()).toList(),
      }),
    );

    if (response.statusCode == 200) {
      return;
    } else if (response.statusCode == 401) {
      await AuthApi.refreshAccessToken();
      return await sendTags(tags);
    } else {
      throw ApiError.fromJson(json.decode(response.body));
    }
  }

  /// Retrieve all the tags that changed
  static Future<void> retrieveTags(DateTime? lastSync) async {
    var client = http.Client();
    var accessToken = await Security.getAccessToken();

    if (accessToken == null || accessToken.isEmpty) {
      return;
    }

    var dateFormatter = DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'");
    String tagUrl = "$url$tags_route";

    if (lastSync != null) {
      tagUrl += "?LastSynchro=${dateFormatter.format(lastSync)}";
    }

    var response = await client.get(
      Uri.parse(tagUrl),
      headers: {HttpHeaders.authorizationHeader: "Bearer $accessToken"},
    );

    if (response.statusCode == 200) {
      List<dynamic> dataList = json.decode(response.body)["tags"];

      for (var data in dataList) {
        var tag = Tag.fromJson(data);
        await TagService.save(tag);
      }

      return;
    } else if (response.statusCode == 401) {
      await AuthApi.refreshAccessToken();
      return await retrieveTags(lastSync);
    } else {
      throw ApiError.fromJson(json.decode(response.body));
    }
  }
}
