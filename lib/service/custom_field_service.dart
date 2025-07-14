import 'package:chic_secret/model/database/custom_field.dart';
import 'package:chic_secret/model/database/entry.dart';
import 'package:chic_secret/utils/database.dart';
import 'package:chic_secret/utils/database_structure.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

class CustomFieldService {
  static Future<void> update(CustomField customField) async {
    await db.update(
      customFieldTable,
      customField.toMap(),
      where: "$columnId = '${customField.id}'",
    );
  }

  static Future<void> save(CustomField customField) async {
    await db.insert(
      customFieldTable,
      customField.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<bool> exists(CustomField customField) async {
    var data = await db.query(
      customFieldTable,
      where: "$columnId = '${customField.id}'",
    );

    return data.isNotEmpty;
  }

  static Future<void> delete(CustomField customField) async {
    customField.deletedAt = DateTime.now();
    customField.updatedAt = DateTime.now();

    await db.update(
      customFieldTable,
      customField.toMap(),
      where: "$columnId = '${customField.id}'",
    );
  }

  static Future<List<CustomField>> getAllByEntry(String entryId) async {
    List<CustomField> customFields = [];
    List<Map<String, dynamic>> maps = await db.query(customFieldTable,
        where:
            "$columnCustomFieldEntryId = '$entryId' AND $columnDeletedAt IS NULL");

    if (maps.isNotEmpty) {
      for (var map in maps) {
        customFields.add(CustomField.fromMap(map));
      }
    }

    return customFields;
  }

  static Future<void> deleteAllFromEntry(String entryId) async {
    var dateFormatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    String date = dateFormatter.format(DateTime.now());

    await db.rawUpdate("""
      UPDATE $customFieldTable 
      SET $columnDeletedAt = '$date', $columnUpdatedAt = '$date' 
      WHERE $columnCustomFieldEntryId = '$entryId'
      """);
  }

  static Future<void> deleteAllFromVault(String vaultId) async {
    var dateFormatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    String date = dateFormatter.format(DateTime.now());

    await db.rawUpdate("""
      UPDATE $customFieldTable
      SET $columnDeletedAt = '$date', $columnUpdatedAt = '$date' 
      WHERE $columnCustomFieldEntryId IN (SELECT $columnId FROM $entryTable WHERE $columnEntryVaultId = '$vaultId')
      """);
  }

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
