import 'package:chic_secret/model/database/category.dart';
import 'package:intl/intl.dart';
import 'package:chic_secret/utils/database_structure.dart';

const String entryTable = "Entry";
const String columnEntryName = "name";
const String columnEntryUsername = "username";
const String columnEntryHash = "hash";
const String columnEntryVaultId = "vault_id";
const String columnEntryCategoryId = "category_id";

class Entry {
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

  Entry({
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

  factory Entry.fromMap(Map<String, dynamic> data) {
    var createdAtString = DateTime.parse(data[columnCreatedAt]);
    var updatedAtString = DateTime.parse(data[columnUpdatedAt]);
    var deletedAtString;

    if (data[columnDeletedAt] != null) {
      deletedAtString = DateTime.parse(data[columnDeletedAt]);
    }

    return Entry(
      id: data[columnId],
      name: data[columnEntryName],
      username: data[columnEntryUsername],
      hash: data[columnEntryHash],
      vaultId: data[columnEntryVaultId],
      categoryId: data[columnEntryCategoryId],
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
      columnEntryName: name,
      columnEntryUsername: username,
      columnEntryHash: hash,
      columnEntryVaultId: vaultId,
      columnEntryCategoryId: categoryId,
      columnCreatedAt: createdAtString,
      columnUpdatedAt: updatedAtString,
      columnDeletedAt: deletedAtString,
    };
  }
}
