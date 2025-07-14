import 'package:chic_secret/model/database/category.dart';
import 'package:chic_secret/utils/database.dart';
import 'package:chic_secret/utils/database_structure.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

class CategoryService {
  static Future<void> delete(Category category) async {
    category.deletedAt = DateTime.now();
    category.updatedAt = DateTime.now();

    await db.update(
      categoryTable,
      category.toMap(),
      where: "$columnId = '${category.id}'",
    );
  }

  static Future<void> update(Category category) async {
    await db.update(
      categoryTable,
      category.toMap(),
      where: "$columnId = '${category.id}'",
    );
  }

  static Future<void> save(Category category) async {
    await db.insert(
      categoryTable,
      category.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<bool> exists(Category category) async {
    var data = await db.query(
      categoryTable,
      where: "$columnId = '${category.id}'",
    );

    return data.isNotEmpty;
  }

  static Future<void> deleteAllFromVault(String vaultId) async {
    var dateFormatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    String date = dateFormatter.format(DateTime.now());

    await db.rawUpdate("""
      UPDATE $categoryTable
      SET $columnDeletedAt = '$date', $columnUpdatedAt = '$date' 
      WHERE $columnCategoryVaultId = '$vaultId'
      """);
  }

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

  static Future<Category?> getFirstByVault(String vaultId) async {
    List<Map<String, dynamic>> maps = await db.query(
      categoryTable,
      where:
          "$columnCategoryVaultId = '$vaultId' and $columnCategoryIsTrash = 0 AND $columnDeletedAt IS NULL",
      orderBy: "$columnCreatedAt ASC",
      limit: 1,
    );

    if (maps.length > 0) {
      return Category.fromMap(maps[0]);
    }

    return null;
  }

  static Future<List<Category>> getAllByVault(String vaultId) async {
    List<Category> categories = [];
    List<Map<String, dynamic>> maps = await db.query(categoryTable,
        where:
            "$columnCategoryVaultId = '$vaultId' AND $columnDeletedAt IS NULL",
        orderBy: "$columnCategoryIsTrash ASC, LOWER($columnCategoryName) ASC");

    if (maps.isNotEmpty) {
      for (var map in maps) {
        categories.add(Category.fromMap(map));
      }
    }

    return categories;
  }

  static Future<List<Category>> getAllByVaultWithoutTrash(
      String vaultId) async {
    List<Category> categories = [];
    List<Map<String, dynamic>> maps = await db.query(
      categoryTable,
      where:
          "$columnCategoryVaultId = '$vaultId' and $columnCategoryIsTrash = 0 AND $columnDeletedAt IS NULL",
      orderBy: "$columnCreatedAt ASC, LOWER($columnCategoryName) ASC",
    );

    if (maps.isNotEmpty) {
      for (var map in maps) {
        categories.add(Category.fromMap(map));
      }
    }

    return categories;
  }

  static Future<List<Category>> getCategoriesToSynchronize(
      DateTime? lastSync) async {
    String? whereQuery;

    if (lastSync != null) {
      var dateFormatter = DateFormat('yyyy-MM-dd HH:mm:ss');
      String lastSyncString = dateFormatter.format(lastSync);
      whereQuery = "$columnUpdatedAt > '$lastSyncString' ";
    }

    List<Map<String, dynamic>> maps = await db.query(
      categoryTable,
      where: whereQuery,
    );

    return List.generate(maps.length, (i) {
      return Category.fromMap(maps[i]);
    });
  }
}
