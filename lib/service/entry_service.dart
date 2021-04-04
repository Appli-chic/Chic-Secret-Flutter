import 'package:chic_secret/model/database/entry.dart';
import 'package:chic_secret/service/category_service.dart';
import 'package:chic_secret/utils/database.dart';

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
  static Future<List<Entry>> getAllByVault(String vaultId) async {
    List<Entry> entries = [];
    List<Map<String, dynamic>> maps =
        await db.query(entryTable, where: "$columnEntryVaultId = '$vaultId'");

    if (maps.isNotEmpty) {
      for (var map in maps) {
        var entry = Entry.fromMap(map);
        entry.category =
            await CategoryService.getCategoryById(entry.categoryId);
        entries.add(entry);
      }
    }

    return entries;
  }

  /// Retrieve all the entries linked to a vault and a category
  static Future<List<Entry>> getAllByVaultAndCategory(
      String vaultId, String categoryId) async {
    List<Entry> entries = [];
    List<Map<String, dynamic>> maps = await db.query(
      entryTable,
      where:
          "$columnEntryVaultId = '$vaultId' and $columnEntryCategoryId = '$categoryId'",
    );

    if (maps.isNotEmpty) {
      for (var map in maps) {
        var entry = Entry.fromMap(map);
        entry.category =
            await CategoryService.getCategoryById(entry.categoryId);
        entries.add(entry);
      }
    }

    return entries;
  }
}
