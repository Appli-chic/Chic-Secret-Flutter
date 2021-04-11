import 'package:intl/intl.dart';
import 'package:chic_secret/utils/database_structure.dart';

const String categoryTable = "category";
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

  /// Transform a map of [data] into a category
  factory Category.fromMap(Map<String, dynamic> data, {String? prefix}) {
    var createdAtString = DateTime.parse(prefix != null
        ? data[prefix + columnCreatedAt]
        : data[columnCreatedAt]);
    var updatedAtString = DateTime.parse(prefix != null
        ? data[prefix + columnUpdatedAt]
        : data[columnUpdatedAt]);
    var deletedAtString;

    var deletedDate =
        prefix != null ? data[prefix + columnDeletedAt] : data[columnDeletedAt];

    if (deletedDate != null) {
      deletedAtString = DateTime.parse(prefix != null
          ? data[prefix + columnDeletedAt]
          : data[columnDeletedAt]);
    }

    return Category(
      id: prefix != null ? data[prefix + columnId] : data[columnId],
      name: prefix != null
          ? data[prefix + columnCategoryName]
          : data[columnCategoryName],
      color: prefix != null
          ? data[prefix + columnCategoryColor]
          : data[columnCategoryColor],
      icon: prefix != null
          ? data[prefix + columnCategoryIcon]
          : data[columnCategoryIcon],
      vaultId: prefix != null
          ? data[prefix + columnCategoryVaultId]
          : data[columnCategoryVaultId],
      createdAt: createdAtString,
      updatedAt: updatedAtString,
      deletedAt: deletedAtString,
    );
  }

  /// Transform a category into a map of data
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
