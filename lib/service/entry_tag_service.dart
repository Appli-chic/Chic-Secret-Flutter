import 'package:chic_secret/model/database/entry.dart';
import 'package:chic_secret/model/database/entry_tag.dart';
import 'package:chic_secret/utils/database.dart';
import 'package:chic_secret/utils/database_structure.dart';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';

class EntryTagService {
  /// Update the entryTag already exists
  static Future<void> update(EntryTag entryTag) async {
    await db.update(
      entryTagTable,
      entryTag.toMap(),
      where:
          "$columnEntryTagEntryId = '${entryTag.entryId}' AND $columnEntryTagTagId = '${entryTag.tagId}'",
    );
  }

  /// Save a [entryTag] into the local database
  static Future<void> save(EntryTag entryTag) async {
    await db.insert(
      entryTagTable,
      entryTag.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Checks if the entryTag already exists
  static Future<bool> exists(EntryTag entryTag) async {
    var data = await db.query(
      entryTagTable,
      where:
          "$columnEntryTagEntryId = '${entryTag.entryId}' AND $columnEntryTagTagId = '${entryTag.tagId}'",
    );

    return data.isNotEmpty;
  }

  /// Delete a [entryTag] from the local database
  static Future<void> delete(String entryId, String tagId) async {
    var dateFormatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    String date = dateFormatter.format(DateTime.now());

    await db.rawUpdate("""
      UPDATE $entryTagTable 
      SET $columnDeletedAt = '$date', $columnUpdatedAt = '$date' 
      WHERE $columnEntryTagEntryId = '$entryId' and $columnEntryTagTagId = '$tagId'
    """);
  }

  /// Delete all the links between tags and the entry
  static Future<void> deleteAllFromEntry(String entryId) async {
    var dateFormatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    String date = dateFormatter.format(DateTime.now());

    await db.rawUpdate("""
      UPDATE $entryTagTable 
      SET $columnDeletedAt = '$date', $columnUpdatedAt = '$date' 
      WHERE $columnEntryTagEntryId = '$entryId'
      """);
  }

  /// Delete all the links between tags and the vault
  static Future<void> deleteAllFromVault(String vaultId) async {
    var dateFormatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    String date = dateFormatter.format(DateTime.now());

    await db.rawUpdate("""
      UPDATE $entryTagTable 
      SET $columnDeletedAt = '$date', $columnUpdatedAt = '$date' 
      WHERE $columnEntryTagEntryId IN (SELECT $columnId FROM $entryTable WHERE $columnEntryVaultId = '$vaultId')
      """);
  }

  /// Delete all the links between tags and the entry
  static Future<void> deleteAllFromTag(String tagId) async {
    var dateFormatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    String date = dateFormatter.format(DateTime.now());

    await db.rawUpdate("""
      UPDATE $entryTagTable 
      SET $columnDeletedAt = '$date', $columnUpdatedAt = '$date' 
      WHERE $columnEntryTagTagId = '$tagId'
      """);
  }

  /// Get all the entry tags to synchronize from the locale database to the server
  static Future<List<EntryTag>> getEntryTagsToSynchronize(
      DateTime? lastSync) async {
    String? whereQuery;

    if (lastSync != null) {
      var dateFormatter = DateFormat('yyyy-MM-dd HH:mm:ss');
      String lastSyncString = dateFormatter.format(lastSync);
      whereQuery = "$columnUpdatedAt > '$lastSyncString' ";
    }

    List<Map<String, dynamic>> maps = await db.query(
      entryTagTable,
      where: whereQuery,
    );

    return List.generate(maps.length, (i) {
      return EntryTag.fromMap(maps[i]);
    });
  }
}
