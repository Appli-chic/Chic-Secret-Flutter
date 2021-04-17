import 'package:chic_secret/model/database/category.dart';
import 'package:chic_secret/utils/database.dart';
import 'package:chic_secret/utils/database_structure.dart';

class CategoryService {
  /// Save a [category] into the local database
  static Future<void> save(Category category) async {
    await db.insert(
      categoryTable,
      category.toMap(),
    );
  }

  /// Retrieve the trash category linked to a vault
  static Future<Category?> getTrashByVault(String vaultId) async {
    List<Map<String, dynamic>> maps = await db.query(
      categoryTable,
      where:
          "$columnCategoryVaultId = '$vaultId' and $columnCategoryIsTrash = 1",
      limit: 1,
    );

    if (maps.length > 0) {
      return Category.fromMap(maps[0]);
    }

    return null;
  }

  /// Retrieve the first category linked to a vault (can't be trash)
  static Future<Category?> getFirstByVault(String vaultId) async {
    List<Map<String, dynamic>> maps = await db.query(
      categoryTable,
      where:
          "$columnCategoryVaultId = '$vaultId' and $columnCategoryIsTrash = 0",
      orderBy: "$columnCreatedAt ASC",
      limit: 1,
    );

    if (maps.length > 0) {
      return Category.fromMap(maps[0]);
    }

    return null;
  }

  /// Retrieve all the categories linked to a vault
  static Future<List<Category>> getAllByVault(String vaultId) async {
    List<Category> categories = [];
    List<Map<String, dynamic>> maps = await db.query(categoryTable,
        where: "$columnCategoryVaultId = '$vaultId'",
        orderBy: "$columnCategoryIsTrash ASC");

    if (maps.isNotEmpty) {
      for (var map in maps) {
        categories.add(Category.fromMap(map));
      }
    }

    return categories;
  }

  /// Retrieve the categories without the trash
  static Future<List<Category>> getAllByVaultWithoutTrash(
      String vaultId) async {
    List<Category> categories = [];
    List<Map<String, dynamic>> maps = await db.query(
      categoryTable,
      where:
          "$columnCategoryVaultId = '$vaultId' and $columnCategoryIsTrash = 0",
    );

    if (maps.isNotEmpty) {
      for (var map in maps) {
        categories.add(Category.fromMap(map));
      }
    }

    return categories;
  }
}
