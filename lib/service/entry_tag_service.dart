import 'package:chic_secret/model/database/entry_tag.dart';
import 'package:chic_secret/utils/database.dart';
import 'package:chic_secret/utils/database_structure.dart';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';

class EntryTagService {
  /// Save a [entryTag] into the local database
  static Future<void> save(EntryTag entryTag) async {
    await db.insert(
      entryTagTable,
      entryTag.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Delete a [entryTag] from the local database
  static Future<void> delete(String entryId, String tagId) async {
    var dateFormatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    String deleteDate = dateFormatter.format(DateTime.now());

    await db.rawUpdate("""
      UPDATE $entryTagTable 
      SET $columnDeletedAt = '$deleteDate' 
      WHERE $columnEntryTagEntryId = '$entryId' and $columnEntryTagTagId = '$tagId'
    """);
  }

  /// Delete all the links between tags and the entry
  static Future<void> deleteAllFromEntry(String entryId) async {
    var dateFormatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    String deleteDate = dateFormatter.format(DateTime.now());

    await db.rawUpdate("""
      UPDATE $entryTagTable 
      SET $columnDeletedAt = '$deleteDate' 
      WHERE $columnEntryTagEntryId = '$entryId'
      """);
  }

  /// Delete all the links between tags and the entry
  static Future<void> deleteAllFromTag(String tagId) async {
    var dateFormatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    String deleteDate = dateFormatter.format(DateTime.now());

    await db.rawUpdate("""
      UPDATE $entryTagTable 
      SET $columnDeletedAt = '$deleteDate' 
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
