import 'package:chic_secret/model/database/category.dart';
import 'package:intl/intl.dart';
import 'package:chic_secret/utils/database_structure.dart';

const String passwordTable = "Password";
const String columnPasswordName = "name";
const String columnPasswordUsername = "username";
const String columnPasswordHash = "hash";
const String columnPasswordVaultId = "vault_id";
const String columnPasswordCategoryId = "category_id";

class Password {
  String id;
  String name;
  String username;
  String hash;
  String vaultId;
  String categoryId;
  DateTime createdAt;
  DateTime updatedAt;
  DateTime? deletedAt;

  Category? category;

  Password({
    required this.id,
    required this.name,
    required this.username,
    required this.hash,
    required this.vaultId,
    required this.categoryId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.category,
  });

  factory Password.fromMap(Map<String, dynamic> data) {
    var createdAtString = DateTime.parse(data['created_at']);
    var updatedAtString = DateTime.parse(data['updated_at']);
    var deletedAtString;

    if (data['deleted_at'] != null) {
      deletedAtString = DateTime.parse(data['deleted_at']);
    }

    return Password(
      id: data[columnId],
      name: data[columnPasswordName],
      username: data[columnPasswordUsername],
      hash: data[columnPasswordHash],
      vaultId: data[columnPasswordVaultId],
      categoryId: data[columnPasswordCategoryId],
      createdAt: createdAtString,
      updatedAt: updatedAtString,
      deletedAt: deletedAtString
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
      columnPasswordName: name,
      columnPasswordUsername: username,
      columnPasswordHash: hash,
      columnPasswordVaultId: vaultId,
      columnPasswordCategoryId: categoryId,
      columnCreatedAt: createdAtString,
      columnUpdatedAt: updatedAtString,
      columnDeletedAt: deletedAtString,
    };
  }
}