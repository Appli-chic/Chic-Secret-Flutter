import 'package:chic_secret/utils/database_structure.dart';
import 'package:intl/intl.dart';

const String tagTable = "tag";
const String columnTagName = "name";
const String columnTagVaultId = "vault_id";

class Tag {
  String id;
  String name;
  String vaultId;
  DateTime createdAt;
  DateTime updatedAt;
  DateTime? deletedAt;

  Tag({
    required this.id,
    required this.name,
    required this.vaultId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory Tag.fromJson(Map<String, dynamic> json) {
    var createdAtString = DateTime.parse(json['CreatedAt']);
    var updatedAtString = DateTime.parse(json['UpdatedAt']);
    var deletedAtString;

    if (json['DeletedAt'] != null) {
      deletedAtString = DateTime.parse(json['DeletedAt']);
    }

    return Tag(
      id: json['ID'],
      name: json['Name'],
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
    data['VaultID'] = vaultId;
    data['CreatedAt'] = createdAtString;
    data['UpdatedAt'] = updatedAtString;
    data['DeletedAt'] = deletedAtString;
    return data;
  }

  factory Tag.fromMap(Map<String, dynamic> data) {
    var createdAtString = DateTime.parse(data[columnCreatedAt]);
    var updatedAtString = DateTime.parse(data[columnUpdatedAt]);
    var deletedAtString;

    if (data[columnDeletedAt] != null) {
      deletedAtString = DateTime.parse(data[columnDeletedAt]);
    }

    return Tag(
      id: data[columnId],
      name: data[columnTagName],
      vaultId: data[columnTagVaultId],
      createdAt: createdAtString,
      updatedAt: updatedAtString,
      deletedAt: deletedAtString,
    );
  }

  /// Transform a tag into a map of data
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
      columnTagName: name,
      columnTagVaultId: vaultId,
      columnCreatedAt: createdAtString,
      columnUpdatedAt: updatedAtString,
      columnDeletedAt: deletedAtString,
    };
  }
}
