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
}
