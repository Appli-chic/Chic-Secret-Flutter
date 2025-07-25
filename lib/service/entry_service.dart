import 'package:chic_secret/model/database/category.dart';
import 'package:chic_secret/model/database/custom_field.dart';
import 'package:chic_secret/model/database/entry.dart';
import 'package:chic_secret/model/database/entry_tag.dart';
import 'package:chic_secret/model/database/tag.dart';
import 'package:chic_secret/service/category_service.dart';
import 'package:chic_secret/service/custom_field_service.dart';
import 'package:chic_secret/service/entry_tag_service.dart';
import 'package:chic_secret/utils/database.dart';
import 'package:chic_secret/utils/database_structure.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

const entryGeneralSelect = """
SELECT DISTINCT e.$columnId, e.$columnEntryName, e.$columnEntryUsername, e.$columnEntryHash,
e.$columnEntryComment, e.$columnEntryVaultId, e.$columnEntryCategoryId, e.$columnEntryPasswordSize, 
e.$columnEntryHashUpdatedAt, e.$columnCreatedAt, e.$columnUpdatedAt, e.$columnDeletedAt, 

c.$columnId as c_$columnId, 
c.$columnCategoryName as c_$columnCategoryName, c.$columnCategoryColor as c_$columnCategoryColor, 
c.$columnCategoryIcon as c_$columnCategoryIcon, c.$columnCategoryIsTrash as c_$columnCategoryIsTrash, 
c.$columnCategoryVaultId as c_$columnCategoryVaultId, c.$columnCreatedAt as c_$columnCreatedAt, 
c.$columnUpdatedAt as c_$columnUpdatedAt, c.$columnDeletedAt as c_$columnDeletedAt

FROM $entryTable as e
LEFT JOIN $categoryTable as c ON c.$columnId = e.$columnEntryCategoryId 
LEFT JOIN $entryTagTable as et ON et.$columnEntryTagEntryId = e.$columnId 
LEFT JOIN $tagTable as t ON t.$columnId = et.$columnEntryTagTagId 
LEFT JOIN $customFieldTable as cf ON cf.$columnCustomFieldEntryId = e.$columnId 
""";

class EntryService {
  static Future<void> update(Entry entry) async {
    await db.update(
      entryTable,
      entry.toMap(),
      where: "$columnId = '${entry.id}'",
    );
  }

  static Future<void> save(Entry entry) async {
    await db.insert(
      entryTable,
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<bool> exists(Entry entry) async {
    var data = await db.query(
      entryTable,
      where: "$columnId = '${entry.id}'",
    );

    return data.isNotEmpty;
  }

  static Future<void> deleteAllFromVault(String vaultId) async {
    var dateFormatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    String date = dateFormatter.format(DateTime.now());

    await db.rawUpdate("""
      UPDATE $entryTable
      SET $columnDeletedAt = '$date', $columnUpdatedAt = '$date', $columnEntryHash = 'deleted'
      WHERE $columnEntryVaultId = '$vaultId'
      """);
  }

  static Future<void> deleteDefinitively(Entry entry) async {
    await EntryTagService.deleteAllFromEntry(entry.id);
    await CustomFieldService.deleteAllFromEntry(entry.id);

    entry.deletedAt = DateTime.now();
    entry.updatedAt = DateTime.now();
    entry.hash = "deleted";

    await db.update(
      entryTable,
      entry.toMap(),
      where: "$columnId = '${entry.id}'",
    );
  }

  static Future<void> moveToAnotherCategory(
      Entry entry, String categoryId) async {
    entry.categoryId = categoryId;

    await db.update(
      entryTable,
      entry.toMap(),
      where: "$columnId = '${entry.id}'",
    );
  }

  static Future<void> moveToTrash(Entry entry) async {
    var category = await CategoryService.getTrashByVault(entry.vaultId);

    if (category != null) {
      entry.categoryId = category.id;
      await db.update(
        entryTable,
        entry.toMap(),
        where: "$columnId = '${entry.id}'",
      );
    }
  }

  static Future<void> moveToTrashAllEntriesFromCategory(
      Category category) async {
    var trashCategory = await CategoryService.getTrashByVault(category.vaultId);

    if (trashCategory != null) {
      await db.rawUpdate("""
      UPDATE $entryTable 
      SET $columnEntryCategoryId = '${trashCategory.id}' 
      WHERE $columnEntryCategoryId = '${category.id}'
      """);
    }
  }

  static Future<List<Entry>> getAllByVault(String vaultId,
      {String? categoryId, String? tagId}) async {
    List<Entry> entries = [];
    var query = entryGeneralSelect +
        "WHERE e.$columnEntryVaultId = '$vaultId' "
            "AND e.$columnDeletedAt IS NULL ";

    if (categoryId != null) {
      query += """
      AND $columnEntryCategoryId = '$categoryId'
      """;
    }

    if (tagId != null) {
      query += """
      AND t.$columnId = '$tagId' 
      """;
    }

    query +=
        "order by c.$columnCategoryIsTrash ASC, LOWER(e.$columnEntryName) ASC";

    var maps = await db.rawQuery(query);
    if (maps.isNotEmpty) {
      for (var map in maps) {
        entries.add(Entry.fromMap(map, categoryPrefix: "c_"));
      }
    }

    return entries;
  }

  static Future<List<Entry>> search(String vaultId, String text,
      {String? categoryId, String? tagId}) async {
    List<Entry> entries = [];

    var query = entryGeneralSelect + "WHERE e.$columnEntryVaultId = '$vaultId'";

    if (categoryId != null) {
      query += """
      AND $columnEntryCategoryId = '$categoryId'
      """;
    }

    if (tagId != null) {
      query += """
      AND t.$columnId = '$tagId'
      """;
    }

    query += """
    AND (e.$columnEntryName LIKE '%$text%' OR e.$columnEntryUsername LIKE '%$text%' 
    OR c.$columnCategoryName LIKE '%$text%' OR t.$columnTagName LIKE '%$text%' 
    OR cf.$columnCustomFieldName LIKE '%$text%' OR cf.$columnCustomFieldValue LIKE '%$text%' 
    OR e.$columnEntryComment LIKE '%$text%') 
    AND e.$columnDeletedAt IS NULL 
    """;

    query +=
        "order by c.$columnCategoryIsTrash ASC, LOWER(e.$columnEntryName) ASC";

    var maps = await db.rawQuery(query);

    if (maps.isNotEmpty) {
      for (var map in maps) {
        entries.add(Entry.fromMap(map, categoryPrefix: "c_"));
      }
    }

    return entries;
  }

  static Future<List<Entry>> findDuplicatedPasswords(
      String vaultId, String password) async {
    List<Entry> entries = [];

    var query = entryGeneralSelect + "WHERE e.$columnEntryVaultId = '$vaultId'";

    query += """
    AND e.$columnEntryHash LIKE '%$password%'
    AND e.$columnDeletedAt IS NULL 
    """;

    query +=
        "order by c.$columnCategoryIsTrash ASC, LOWER(e.$columnEntryName) ASC";

    var maps = await db.rawQuery(query);

    if (maps.isNotEmpty) {
      for (var map in maps) {
        entries.add(Entry.fromMap(map, categoryPrefix: "c_"));
      }
    }

    return entries;
  }

  static Future<List<Entry>> getEntriesWithoutPasswordLength() async {
    List<Map<String, dynamic>> maps = await db.query(
      entryTable,
      where:
          "($columnEntryPasswordSize IS NULL OR $columnEntryPasswordSize = 0) AND $columnDeletedAt IS NULL ",
    );

    return List.generate(maps.length, (i) {
      return Entry.fromMap(maps[i]);
    });
  }

  static Future<List<Entry>> getEntriesToSynchronize(DateTime? lastSync) async {
    String? whereQuery;

    if (lastSync != null) {
      var dateFormatter = DateFormat('yyyy-MM-dd HH:mm:ss');
      String lastSyncString = dateFormatter.format(lastSync);
      whereQuery = "$columnUpdatedAt > '$lastSyncString' ";
    }

    List<Map<String, dynamic>> maps = await db.query(
      entryTable,
      where: whereQuery,
    );

    return List.generate(maps.length, (i) {
      return Entry.fromMap(maps[i]);
    });
  }
}
