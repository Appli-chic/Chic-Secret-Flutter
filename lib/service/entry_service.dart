import 'package:chic_secret/model/database/category.dart';
import 'package:chic_secret/model/database/entry.dart';
import 'package:chic_secret/utils/database.dart';
import 'package:chic_secret/utils/database_structure.dart';

const entryWithCategoryGeneralSelect = """
SELECT e.$columnId, e.$columnEntryName, e.$columnEntryUsername, e.$columnEntryHash,
e.$columnEntryVaultId, e.$columnEntryCategoryId, e.$columnCreatedAt, 
e.$columnUpdatedAt, e.$columnDeletedAt, 

c.$columnId as c_$columnId, 
c.$columnCategoryName as c_$columnCategoryName, c.$columnCategoryColor as c_$columnCategoryColor, 
c.$columnCategoryIcon as c_$columnCategoryIcon, c.$columnCategoryVaultId as c_$columnCategoryVaultId, 
c.$columnCreatedAt as c_$columnCreatedAt, c.$columnUpdatedAt as c_$columnUpdatedAt, 
c.$columnDeletedAt as c_$columnDeletedAt

FROM $entryTable as e
LEFT JOIN $categoryTable as c ON c.$columnId = e.$columnEntryCategoryId
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
  static Future<List<Entry>> getAllByVault(String vaultId) async {
    List<Entry> entries = [];
    var maps = await db.rawQuery(entryWithCategoryGeneralSelect +
        """
    WHERE e.$columnEntryVaultId = '$vaultId'
    """);

    if (maps.isNotEmpty) {
      for (var map in maps) {
        entries.add(Entry.fromMap(map, categoryPrefix: "c_"));
      }
    }

    return entries;
  }

  /// Retrieve all the entries linked to a vault and a category
  static Future<List<Entry>> getAllByVaultAndCategory(
      String vaultId, String categoryId) async {
    List<Entry> entries = [];
    var maps = await db.rawQuery(entryWithCategoryGeneralSelect +
        """
    WHERE e.$columnEntryVaultId = '$vaultId'
    AND $columnEntryCategoryId = '$categoryId'
    """);

    if (maps.isNotEmpty) {
      for (var map in maps) {
        entries.add(Entry.fromMap(map, categoryPrefix: "c_"));
      }
    }

    return entries;
  }

  /// Search all the entries linked to a vault.
  /// The text filter by everything that defines a password
  static Future<List<Entry>> searchByVault(String vaultId, String text) async {
    List<Entry> entries = [];

    var maps = await db.rawQuery(entryWithCategoryGeneralSelect +
        """
    WHERE e.$columnEntryVaultId = '$vaultId'
    AND (e.$columnEntryName LIKE '%$text%' OR e.$columnEntryUsername LIKE '%$text%' 
    OR c.$columnCategoryName LIKE '%$text%')
    """);

    if (maps.isNotEmpty) {
      for (var map in maps) {
        entries.add(Entry.fromMap(map, categoryPrefix: "c_"));
      }
    }

    return entries;
  }

  /// Search all the entries linked to a vault and a category.
  /// The text filter by everything that defines a password
  static Future<List<Entry>> searchByVaultAndCategory(
      String vaultId, String categoryId, String text) async {
    List<Entry> entries = [];

    var maps = await db.rawQuery(entryWithCategoryGeneralSelect +
        """
    WHERE e.$columnEntryVaultId = '$vaultId'
    AND $columnEntryCategoryId = '$categoryId'
    AND (e.$columnEntryName LIKE '%$text%' OR e.$columnEntryUsername LIKE '%$text%' 
    OR c.$columnCategoryName LIKE '%$text%')
    """);

    if (maps.isNotEmpty) {
      for (var map in maps) {
        entries.add(Entry.fromMap(map, categoryPrefix: "c_"));
      }
    }

    return entries;
  }
}
