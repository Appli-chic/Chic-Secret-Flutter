import 'package:chic_secret/model/database/custom_field.dart';
import 'package:chic_secret/utils/database.dart';
import 'package:chic_secret/utils/database_structure.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

class CustomFieldService {
  /// Save a [customField] into the local database
  static Future<void> save(CustomField customField) async {
    await db.insert(
      customFieldTable,
      customField.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Delete a [customField] from the local database
  static Future<void> delete(String customFieldId) async {
    await db.delete(
      customFieldTable,
      where: "$columnId = '$customFieldId'",
    );
  }

  /// Retrieve all the custom fields linked to an entry
  static Future<List<CustomField>> getAllByEntry(String entryId) async {
    List<CustomField> customFields = [];
    List<Map<String, dynamic>> maps = await db.query(customFieldTable,
        where: "$columnCustomFieldEntryId = '$entryId'");

    if (maps.isNotEmpty) {
      for (var map in maps) {
        customFields.add(CustomField.fromMap(map));
      }
    }

    return customFields;
  }

  /// Delete all the custom fields of an entry
  static Future<void> deleteAllFromEntry(String entryId) async {
    await db.delete(
      customFieldTable,
      where: "$columnCustomFieldEntryId = '$entryId'",
    );
  }

  /// Get all the custom fields to synchronize from the locale database to the server
  static Future<List<CustomField>> getCustomFieldsToSynchronize(
      DateTime? lastSync) async {
    String? whereQuery;

    if (lastSync != null) {
      var dateFormatter = DateFormat('yyyy-MM-dd HH:mm:ss');
      String lastSyncString = dateFormatter.format(lastSync);
      whereQuery = "$columnUpdatedAt > '$lastSyncString' ";
    }

    List<Map<String, dynamic>> maps = await db.query(
      customFieldTable,
      where: whereQuery,
    );

    return List.generate(maps.length, (i) {
      return CustomField.fromMap(maps[i]);
    });
  }
}
