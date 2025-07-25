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
const String columnEntryPasswordSize = "password_size";
const String columnEntryHashUpdatedAt = "hash_updated_at";

class Entry {
  String id;
  String name;
  String username;
  String hash;
  String? comment;
  String vaultId;
  String categoryId;
  int? passwordSize;
  DateTime? hashUpdatedAt;
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
    this.passwordSize,
    this.hashUpdatedAt,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.category,
  });

  factory Entry.fromJson(Map<String, dynamic> json) {
    var createdAtString = DateTime.parse(json['CreatedAt']);
    var updatedAtString = DateTime.parse(json['UpdatedAt']);
    var deletedAtString;

    if (json['DeletedAt'] != null) {
      deletedAtString = DateTime.parse(json['DeletedAt']);
    }

    return Entry(
      id: json['ID'],
      name: json['Name'],
      username: json['Username'],
      hash: json['Hash'],
      comment: json['Comment'],
      vaultId: json['VaultID'],
      categoryId: json['CategoryID'],
      passwordSize: json['PasswordSize'],
      hashUpdatedAt: json['HashUpdatedAt'],
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
    data['Username'] = username;
    data['Hash'] = hash;
    data['Comment'] = comment;
    data['VaultID'] = vaultId;
    data['CategoryID'] = categoryId;
    data['PasswordSize'] = passwordSize;
    data['HashUpdatedAt'] = hashUpdatedAt;
    data['CreatedAt'] = createdAtString;
    data['UpdatedAt'] = updatedAtString;
    data['DeletedAt'] = deletedAtString;
    return data;
  }

  factory Entry.fromMap(Map<String, dynamic> data, {String? categoryPrefix}) {
    var createdAtString = DateTime.parse(data[columnCreatedAt]);
    var updatedAtString = DateTime.parse(data[columnUpdatedAt]);
    var deletedAtString;
    var hashUpdatedAtString;

    if (data[columnDeletedAt] != null) {
      deletedAtString = DateTime.parse(data[columnDeletedAt]);
    }

    if (data[columnEntryHashUpdatedAt] != null) {
      hashUpdatedAtString = DateTime.parse(data[columnEntryHashUpdatedAt]);
    }

    return Entry(
      id: data[columnId],
      name: data[columnEntryName],
      username: data[columnEntryUsername],
      hash: data[columnEntryHash],
      comment: data[columnEntryComment],
      vaultId: data[columnEntryVaultId],
      categoryId: data[columnEntryCategoryId],
      passwordSize: data[columnEntryPasswordSize],
      hashUpdatedAt: hashUpdatedAtString,
      createdAt: createdAtString,
      updatedAt: updatedAtString,
      deletedAt: deletedAtString,
      category: categoryPrefix != null
          ? Category.fromMap(data, prefix: categoryPrefix)
          : null,
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
      columnEntryComment: comment,
      columnEntryVaultId: vaultId,
      columnEntryCategoryId: categoryId,
      columnEntryPasswordSize: passwordSize,
      columnEntryHashUpdatedAt: hashUpdatedAt,
      columnCreatedAt: createdAtString,
      columnUpdatedAt: updatedAtString,
      columnDeletedAt: deletedAtString,
    };
  }
}
