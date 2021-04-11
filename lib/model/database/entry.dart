import 'package:chic_secret/model/database/category.dart';
import 'package:chic_secret/model/database/tag.dart';
import 'package:intl/intl.dart';
import 'package:chic_secret/utils/database_structure.dart';

const String entryTable = "entry";
const String columnEntryName = "name";
const String columnEntryUsername = "username";
const String columnEntryHash = "hash";
const String columnEntryComment = "comment";
const String columnEntryVaultId = "vault_id";
const String columnEntryCategoryId = "category_id";

class Entry {
  String id;
  String name;
  String username;
  String hash;
  String? comment;
  String vaultId;
  String categoryId;
  DateTime createdAt;
  DateTime updatedAt;
  DateTime? deletedAt;

  Category? category;
  List<Tag> tags = [];

  Entry({
    required this.id,
    required this.name,
    required this.username,
    required this.hash,
    this.comment,
    required this.vaultId,
    required this.categoryId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.category,
  });

  /// Transform a map of [data] into an entry
  factory Entry.fromMap(Map<String, dynamic> data, {String? categoryPrefix}) {
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
      comment: data[columnEntryComment],
      vaultId: data[columnEntryVaultId],
      categoryId: data[columnEntryCategoryId],
      createdAt: createdAtString,
      updatedAt: updatedAtString,
      deletedAt: deletedAtString,
      category: categoryPrefix != null
          ? Category.fromMap(data, prefix: categoryPrefix)
          : null,
    );
  }

  /// Transform an entry into a map of data
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
      columnEntryComment: comment,
      columnEntryVaultId: vaultId,
      columnEntryCategoryId: categoryId,
      columnCreatedAt: createdAtString,
      columnUpdatedAt: updatedAtString,
      columnDeletedAt: deletedAtString,
    };
  }
}
