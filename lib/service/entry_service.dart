import 'package:chic_secret/model/database/entry.dart';
import 'package:chic_secret/service/category_service.dart';
import 'package:chic_secret/utils/database.dart';

class EntryService {
  static Future<Entry> save(Entry entry) async {
    await db.insert(
      entryTable,
      entry.toMap(),
    );

    return entry;
  }

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
}
