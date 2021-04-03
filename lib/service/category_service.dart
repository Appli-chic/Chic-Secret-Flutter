import 'package:chic_secret/model/database/category.dart';
import 'package:chic_secret/utils/database.dart';
import 'package:chic_secret/utils/database_structure.dart';

class CategoryService {
  static Future<Category> save(Category category) async {
    await db.insert(
      categoryTable,
      category.toMap(),
    );
    return category;
  }

  static Future<List<Category>> getAllByVault(String vaultId) async {
    List<Category> categories = [];
    List<Map<String, dynamic>> maps = await db.query(
      categoryTable,
      where: "$columnCategoryVaultId = '$vaultId'"
    );

    if (maps.isNotEmpty) {
      for (var map in maps) {
        categories.add(Category.fromMap(map));
      }
    }

    return categories;
  }

  static Future<Category?> getCategoryById(String categoryId) async {
    Category? category;
    List<Map<String, dynamic>> maps = await db.query(
        categoryTable,
        where: "$columnId = '$categoryId'"
    );

    if (maps.isNotEmpty) {
      category = Category.fromMap(maps[0]);
    }

    return category;
  }
}
