import 'package:chic_secret/model/database/category.dart';
import 'package:chic_secret/utils/database.dart';
import 'package:chic_secret/utils/database_structure.dart';

class CategoryService {
  /// Save a [category] into the local database
  static Future<Category> save(Category category) async {
    await db.insert(
      categoryTable,
      category.toMap(),
    );
    return category;
  }

  /// Retrieve the first category linked to a vault
  static Future<Category?> getFirstByVault(String vaultId) async {
    List<Map<String, dynamic>> maps = await db.query(
      categoryTable,
      where: "$columnCategoryVaultId = '$vaultId'",
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
        where: "$columnCategoryVaultId = '$vaultId'");

    if (maps.isNotEmpty) {
      for (var map in maps) {
        categories.add(Category.fromMap(map));
      }
    }

    return categories;
  }

  /// Retrieve the category from it's id
  static Future<Category?> getCategoryById(String categoryId) async {
    Category? category;
    List<Map<String, dynamic>> maps =
        await db.query(categoryTable, where: "$columnId = '$categoryId'");

    if (maps.isNotEmpty) {
      category = Category.fromMap(maps[0]);
    }

    return category;
  }
}
