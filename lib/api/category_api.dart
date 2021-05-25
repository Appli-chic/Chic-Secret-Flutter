import 'dart:convert';
import 'dart:io';

import 'package:chic_secret/api/auth_api.dart';
import 'package:chic_secret/model/api_error.dart';
import 'package:chic_secret/service/category_service.dart';
import 'package:chic_secret/utils/constant.dart';
import 'package:chic_secret/utils/security.dart';
import 'package:http/http.dart' as http;
import 'package:chic_secret/model/database/category.dart';
import 'package:intl/intl.dart';

const String categories_route = "api/categories";

class CategoryApi {
  /// Send the categories to synchronize to the server
  static Future<void> sendCategories(List<Category> categories) async {
    var client = http.Client();
    var accessToken = await Security.getAccessToken();

    if (accessToken == null || accessToken.isEmpty) {
      return;
    }

    var response = await client.post(
      Uri.parse("$url$categories_route"),
      headers: {HttpHeaders.authorizationHeader: "Bearer $accessToken"},
      body: json.encode({
        "categories": categories.map((v) => v.toJson()).toList(),
      }),
    );

    if (response.statusCode == 200) {
      return;
    } else if (response.statusCode == 401) {
      await AuthApi.refreshAccessToken();
      return await sendCategories(categories);
    } else {
      throw ApiError.fromJson(json.decode(response.body));
    }
  }

  /// Retrieve all the categories that changed
  static Future<void> retrieveCategories(DateTime? lastSync) async {
    var client = http.Client();
    var accessToken = await Security.getAccessToken();

    if (accessToken == null || accessToken.isEmpty) {
      return;
    }

    var dateFormatter = DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'");
    String categoryUrl = "$url$categories_route";

    if (lastSync != null) {
      categoryUrl += "?LastSynchro=${dateFormatter.format(lastSync)}";
    }

    var response = await client.get(
      Uri.parse(categoryUrl),
      headers: {HttpHeaders.authorizationHeader: "Bearer $accessToken"},
    );

    if (response.statusCode == 200) {
      List<dynamic> dataList = json.decode(response.body)["categories"];

      for (var data in dataList) {
        var category = Category.fromJson(data);
        await CategoryService.save(category);
      }

      return;
    } else if (response.statusCode == 401) {
      await AuthApi.refreshAccessToken();
      return await retrieveCategories(lastSync);
    } else {
      throw ApiError.fromJson(json.decode(response.body));
    }
  }
}
