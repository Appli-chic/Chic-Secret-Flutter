import 'package:chic_secret/model/database/entry_tag.dart';
import 'package:chic_secret/utils/database.dart';

class EntryTagService {
  /// Save a [entryTag] into the local database
  static Future<void> save(EntryTag entryTag) async {
    await db.insert(
      entryTagTable,
      entryTag.toMap(),
    );
  }

  /// Delete a [entryTag] from the local database
  static Future<void> delete(String entryId, String tagId) async {
    await db.delete(
      entryTagTable,
      where:
          "$columnEntryTagEntryId = '$entryId' and $columnEntryTagTagId = '$tagId'",
    );
  }

  /// Delete all the links between tags and the entry
  static Future<void> deleteAllFromEntry(String entryId) async {
    await db.delete(
      entryTagTable,
      where: "$columnEntryTagEntryId = '$entryId'",
    );
  }
}
