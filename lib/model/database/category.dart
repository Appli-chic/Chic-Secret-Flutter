import 'package:chic_secret/utils/database.dart';
import 'package:intl/intl.dart';
import 'package:chic_secret/utils/database_structure.dart';

const String categoryTable = "category";
const String columnCategoryName = "name";
const String columnCategoryColor = "color";
const String columnCategoryIcon = "icon";
const String columnCategoryIsTrash = "is_trash";
const String columnCategoryVaultId = "vault_id";

class Category {
  String id;
  String name;
  String color;
  int icon;
  bool isTrash;
  String vaultId;
  DateTime createdAt;
  DateTime updatedAt;
  DateTime? deletedAt;

  Category({
    required this.id,
    required this.name,
    required this.color,
    required this.icon,
    required this.isTrash,
    required this.vaultId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  /// Transform a json to a category
  factory Category.fromJson(Map<String, dynamic> json) {
    var createdAtString = DateTime.parse(json['CreatedAt']);
    var updatedAtString = DateTime.parse(json['UpdatedAt']);
    var deletedAtString;

    if (json['DeletedAt'] != null) {
      deletedAtString = DateTime.parse(json['DeletedAt']);
    }

    return Category(
      id: json['ID'],
      name: json['Name'],
      icon: json['Icon'],
      color: json['Color'],
      isTrash: json['IsTrash'],
      vaultId: json['VaultID'],
      createdAt: createdAtString,
      updatedAt: updatedAtString,
      deletedAt: deletedAtString,
    );
  }

  Map<String, dynamic> toJson() {
    var dateFormatter = DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'");
    String createdAtString = dateFormatter.format(createdAt);
    String updatedAtString = dateFormatter.format(updatedAt);
    String? deletedAtString;

    if (deletedAt != null) {
      deletedAtString = dateFormatter.format(deletedAt!);
    }

    final Map<String, dynamic> data = Map<String, dynamic>();
    data['ID'] = id;
    data['Name'] = name;
    data['Icon'] = icon;
    data['Color'] = color;
    data['IsTrash'] = isTrash;
    data['VaultID'] = vaultId;
    data['CreatedAt'] = createdAtString;
    data['UpdatedAt'] = updatedAtString;
    data['DeletedAt'] = deletedAtString;
    return data;
  }

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
      isTrash: prefix != null
          ? transformIntToBool(data[prefix + columnCategoryIsTrash])
          : transformIntToBool(data[columnCategoryIsTrash]),
      vaultId: prefix != null
          ? data[prefix + columnCategoryVaultId]
          : data[columnCategoryVaultId],
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
      columnCategoryIsTrash: isTrash ? 1 : 0,
      columnCategoryVaultId: vaultId,
      columnCreatedAt: createdAtString,
      columnUpdatedAt: updatedAtString,
      columnDeletedAt: deletedAtString,
    };
  }
}
