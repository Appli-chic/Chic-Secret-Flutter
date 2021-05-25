import 'dart:convert';
import 'dart:io';

import 'package:chic_secret/api/auth_api.dart';
import 'package:chic_secret/model/api_error.dart';
import 'package:chic_secret/model/database/custom_field.dart';
import 'package:chic_secret/service/custom_field_service.dart';
import 'package:chic_secret/utils/constant.dart';
import 'package:chic_secret/utils/security.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

const String custom_fields_route = "api/custom-fields";

class CustomFieldApi {
  /// Send the custom fields to synchronize to the server
  static Future<void> sendCustomFields(List<CustomField> customFields) async {
    var client = http.Client();
    var accessToken = await Security.getAccessToken();

    if (accessToken == null || accessToken.isEmpty) {
      return;
    }

    var response = await client.post(
      Uri.parse("$url$custom_fields_route"),
      headers: {HttpHeaders.authorizationHeader: "Bearer $accessToken"},
      body: json.encode({
        "CustomFields": customFields.map((v) => v.toJson()).toList(),
      }),
    );

    if (response.statusCode == 200) {
      return;
    } else if (response.statusCode == 401) {
      await AuthApi.refreshAccessToken();
      return await sendCustomFields(customFields);
    } else {
      throw ApiError.fromJson(json.decode(response.body));
    }
  }

  /// Retrieve all the custom fields that changed
  static Future<void> retrieveCustomFields(DateTime? lastSync) async {
    var client = http.Client();
    var accessToken = await Security.getAccessToken();

    if (accessToken == null || accessToken.isEmpty) {
      return;
    }

    var dateFormatter = DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'");
    String customFieldUrl = "$url$custom_fields_route";

    if (lastSync != null) {
      customFieldUrl += "?LastSynchro=${dateFormatter.format(lastSync)}";
    }

    var response = await client.get(
      Uri.parse(customFieldUrl),
      headers: {HttpHeaders.authorizationHeader: "Bearer $accessToken"},
    );

    if (response.statusCode == 200) {
      List<dynamic> dataList = json.decode(response.body)["custom_fields"];

      for (var data in dataList) {
        var customField = CustomField.fromJson(data);
        await CustomFieldService.save(customField);
      }

      return;
    } else if (response.statusCode == 401) {
      await AuthApi.refreshAccessToken();
      return await retrieveCustomFields(lastSync);
    } else {
      throw ApiError.fromJson(json.decode(response.body));
    }
  }
}
