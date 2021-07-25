import 'package:chic_secret/model/database/entry.dart';
import 'package:chic_secret/model/database/entry_tag.dart';
import 'package:chic_secret/model/database/tag.dart';
import 'package:chic_secret/utils/database.dart';
import 'package:chic_secret/utils/database_structure.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

class TagService {
  /// Delete a [tag] from the local database
  static Future<void> delete(Tag tag) async {
    tag.deletedAt = DateTime.now();
    tag.updatedAt = DateTime.now();

    await db.update(
      tagTable,
      tag.toMap(),
      where: "$columnId = '${tag.id}'",
    );
  }

  /// Save a [tag] into the local database
  static Future<void> save(Tag tag) async {
    await db.insert(
      tagTable,
      tag.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Update a [tag] in the local database
  static Future<void> update(Tag tag) async {
    await db.update(
      tagTable,
      tag.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
      where: "$columnId = '${tag.id}'",
    );
  }

  /// Checks if the tag already exists
  static Future<bool> exists(Tag tag) async {
    var data = await db.query(
      tagTable,
      where: "$columnId = '${tag.id}'",
    );

    return data.isNotEmpty;
  }

  /// Retrieve a tag that has this exact name in the specified vault
  static Future<Tag?> getTagByVaultByName(String vaultId, String name) async {
    List<Map<String, dynamic>> maps = await db.query(
      tagTable,
      where:
          "$columnTagVaultId = '$vaultId' and $columnTagName = '$name' AND $columnDeletedAt IS NULL",
    );

    if (maps.isNotEmpty) {
      return Tag.fromMap(maps[0]);
    }

    return null;
  }

  /// Delete all the tags from the vault
  static Future<void> deleteAllFromVault(String vaultId) async {
    var dateFormatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    String date = dateFormatter.format(DateTime.now());

    await db.rawUpdate("""
      UPDATE $tagTable
      SET $columnDeletedAt = '$date', $columnUpdatedAt = '$date' 
      WHERE $columnId IN (SELECT $columnEntryTagTagId FROM $entryTagTable 
        LEFT JOIN $entryTable ON $entryTable.$columnId = $entryTagTable.$columnEntryTagEntryId
        WHERE $entryTable.$columnEntryVaultId = '$vaultId')
      """);
  }

  /// Retrieve all the tags linked to a vault
  static Future<List<Tag>> getAllByVault(String vaultId) async {
    List<Tag> tags = [];
    List<Map<String, dynamic>> maps = await db.query(
      tagTable,
      where: "$columnTagVaultId = '$vaultId' AND $columnDeletedAt IS NULL",
    );

    if (maps.isNotEmpty) {
      for (var map in maps) {
        tags.add(Tag.fromMap(map));
      }
    }

    return tags;
  }

  /// Search the tags linked in the vault
  static Future<List<Tag>> searchingTagInVault(
      String vaultId, String text) async {
    List<Tag> tags = [];
    List<Map<String, dynamic>> maps = await db.query(
      tagTable,
      where:
          "$columnTagVaultId = '$vaultId' and $columnTagName LIKE '%$text%' AND $columnDeletedAt IS NULL",
    );

    if (maps.isNotEmpty) {
      for (var map in maps) {
        tags.add(Tag.fromMap(map));
      }
    }

    return tags;
  }

  /// Retrieve all the tags linked to an entry
  static Future<List<Tag>> getAllByEntry(String entryId) async {
    List<Tag> tags = [];

    var query = """
    SELECT t.$columnId, t.$columnTagName, t.$columnTagVaultId, t.$columnCreatedAt, 
    t.$columnUpdatedAt, t.$columnDeletedAt
    FROM $tagTable as t
    LEFT JOIN $entryTagTable as et ON et.$columnEntryTagTagId = t.$columnId
    WHERE et.$columnEntryTagEntryId = '$entryId' AND t.$columnDeletedAt IS NULL 
    AND et.$columnDeletedAt IS NULL
    """;

    var maps = await db.rawQuery(query);
    if (maps.isNotEmpty) {
      for (var map in maps) {
        tags.add(Tag.fromMap(map));
      }
    }

    return tags;
  }

  /// Get all the tags to synchronize from the locale database to the server
  static Future<List<Tag>> getTagsToSynchronize(DateTime? lastSync) async {
    String? whereQuery;

    if (lastSync != null) {
      var dateFormatter = DateFormat('yyyy-MM-dd HH:mm:ss');
      String lastSyncString = dateFormatter.format(lastSync);
      whereQuery = "$columnUpdatedAt > '$lastSyncString' ";
    }

    List<Map<String, dynamic>> maps = await db.query(
      tagTable,
      where: whereQuery,
    );

    return List.generate(maps.length, (i) {
      return Tag.fromMap(maps[i]);
    });
  }
}
