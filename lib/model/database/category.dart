import 'package:intl/intl.dart';
import 'package:chic_secret/utils/database_structure.dart';

const String categoryTable = "Category";
const String columnCategoryName = "name";
const String columnCategoryColor = "color";
const String columnCategoryIcon = "icon";
const String columnCategoryVaultId = "vault_id";

class Category {
  String id;
  String name;
  String color;
  int icon;
  String vaultId;
  DateTime createdAt;
  DateTime updatedAt;
  DateTime? deletedAt;

  Category({
    required this.id,
    required this.name,
    required this.color,
    required this.icon,
    required this.vaultId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory Category.fromMap(Map<String, dynamic> data) {
    var createdAtString = DateTime.parse(data[columnCreatedAt]);
    var updatedAtString = DateTime.parse(data[columnUpdatedAt]);
    var deletedAtString;

    if (data[columnDeletedAt] != null) {
      deletedAtString = DateTime.parse(data[columnDeletedAt]);
    }

    return Category(
      id: data[columnId],
      name: data[columnCategoryName],
      color: data[columnCategoryColor],
      icon: data[columnCategoryIcon],
      vaultId: data[columnCategoryVaultId],
      createdAt: createdAtString,
      updatedAt: updatedAtString,
      deletedAt: deletedAtString,
    );
  }

  Map<String, dynamic> toMap() {
    var dateFormatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    String createdAtString = dateFormatter.format(createdAt);
    String updatedAtString = dateFormatter.format(updatedAt);
    String? deletedAtString;

    if (this.deletedAt != null) {
      deletedAtString = dateFormatter.format(deletedAt!);
    }

    return {
      columnId: id,
      columnCategoryName: name,
      columnCategoryColor: color,
      columnCategoryIcon: icon,
      columnCategoryVaultId: vaultId,
      columnCreatedAt: createdAtString,
      columnUpdatedAt: updatedAtString,
      columnDeletedAt: deletedAtString,
    };
  }
}
