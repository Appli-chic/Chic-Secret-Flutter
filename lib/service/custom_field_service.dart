import 'package:chic_secret/model/database/custom_field.dart';
import 'package:chic_secret/utils/database.dart';
import 'package:chic_secret/utils/database_structure.dart';

class CustomFieldService {
  /// Save a [customField] into the local database
  static Future<void> save(CustomField customField) async {
    await db.insert(
      customFieldTable,
      customField.toMap(),
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
}
