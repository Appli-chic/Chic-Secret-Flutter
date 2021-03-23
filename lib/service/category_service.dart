import 'package:chic_secret/model/database/category.dart';
import 'package:chic_secret/utils/database.dart';

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
    );

    if (maps.isNotEmpty) {
      for (var map in maps) {
        categories.add(Category.fromMap(map));
      }
    }

    return categories;
  }
}
