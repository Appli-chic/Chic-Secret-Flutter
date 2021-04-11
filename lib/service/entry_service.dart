import 'package:chic_secret/model/database/category.dart';
import 'package:chic_secret/model/database/custom_field.dart';
import 'package:chic_secret/model/database/entry.dart';
import 'package:chic_secret/model/database/tag.dart';
import 'package:chic_secret/utils/database.dart';
import 'package:chic_secret/utils/database_structure.dart';

const entryGeneralSelect = """
SELECT DISTINCT e.$columnId, e.$columnEntryName, e.$columnEntryUsername, e.$columnEntryHash,
e.$columnEntryComment, e.$columnEntryVaultId, e.$columnEntryCategoryId, e.$columnCreatedAt, 
e.$columnUpdatedAt, e.$columnDeletedAt, 

c.$columnId as c_$columnId, 
c.$columnCategoryName as c_$columnCategoryName, c.$columnCategoryColor as c_$columnCategoryColor, 
c.$columnCategoryIcon as c_$columnCategoryIcon, c.$columnCategoryVaultId as c_$columnCategoryVaultId, 
c.$columnCreatedAt as c_$columnCreatedAt, c.$columnUpdatedAt as c_$columnUpdatedAt, 
c.$columnDeletedAt as c_$columnDeletedAt

FROM $entryTable as e
LEFT JOIN $categoryTable as c ON c.$columnId = e.$columnEntryCategoryId
LEFT JOIN $tagTable as t ON t.$columnTagEntryId = e.$columnId 
LEFT JOIN $customFieldTable as cf ON cf.$columnCustomFieldEntryId = e.$columnId 
""";

class EntryService {
  /// Save an [entry] into the local database
  static Future<Entry> save(Entry entry) async {
    await db.insert(
      entryTable,
      entry.toMap(),
    );

    return entry;
  }

  /// Retrieve all the entries linked to a vault
  static Future<List<Entry>> getAllByVault(String vaultId,
      {String? categoryId, String? tagId}) async {
    List<Entry> entries = [];
    var query = entryGeneralSelect + "WHERE e.$columnEntryVaultId = '$vaultId'";

    // Filter on category if selected
    if (categoryId != null) {
      query += """
      AND $columnEntryCategoryId = '$categoryId'
      """;
    }

    // Filter on tag if selected
    if (tagId != null) {
      query += """
      AND t.$columnId = '$tagId'
      """;
    }

    var maps = await db.rawQuery(query);
    if (maps.isNotEmpty) {
      for (var map in maps) {
        entries.add(Entry.fromMap(map, categoryPrefix: "c_"));
      }
    }

    return entries;
  }

  /// Search all the entries linked to a vault.
  /// The text filter by everything that defines a password
  static Future<List<Entry>> search(String vaultId, String text,
      {String? categoryId, String? tagId}) async {
    List<Entry> entries = [];

    var query = entryGeneralSelect + "WHERE e.$columnEntryVaultId = '$vaultId'";

    // Filter on category if selected
    if (categoryId != null) {
      query += """
      AND $columnEntryCategoryId = '$categoryId'
      """;
    }

    // Filter on tag if selected
    if (tagId != null) {
      query += """
      AND t.$columnId = '$tagId'
      """;
    }

    // Add search
    query += """
    AND (e.$columnEntryName LIKE '%$text%' OR e.$columnEntryUsername LIKE '%$text%' 
    OR c.$columnCategoryName LIKE '%$text%' OR t.$columnTagName LIKE '%$text%' 
    OR cf.$columnCustomFieldName LIKE '%$text%' OR cf.$columnCustomFieldValue LIKE '%$text%' 
    OR e.$columnEntryComment LIKE '%$text%')
    """;

    var maps = await db.rawQuery(query);

    if (maps.isNotEmpty) {
      for (var map in maps) {
        entries.add(Entry.fromMap(map, categoryPrefix: "c_"));
      }
    }

    return entries;
  }
}
