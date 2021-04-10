import 'package:chic_secret/model/database/tag.dart';
import 'package:chic_secret/utils/database.dart';

class TagService {
  /// Save a [tag] into the local database
  static Future<Tag> save(Tag tag) async {
    await db.insert(
      tagTable,
      tag.toMap(),
    );

    return tag;
  }

  /// Retrieve all the tags linked to a vault
  static Future<List<Tag>> getAllByVault(String vaultId) async {
    List<Tag> tags = [];
    List<Map<String, dynamic>> maps =
        await db.query(tagTable, where: "$columnTagVaultId = '$vaultId'");

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
      where: "$columnTagVaultId = '$vaultId' and $columnTagName LIKE '%$text%'",
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
    List<Map<String, dynamic>> maps =
        await db.query(tagTable, where: "$columnTagEntryId = '$entryId'");

    if (maps.isNotEmpty) {
      for (var map in maps) {
        tags.add(Tag.fromMap(map));
      }
    }

    return tags;
  }
}
