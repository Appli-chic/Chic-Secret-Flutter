import 'package:chic_secret/utils/database_structure.dart';
import 'package:intl/intl.dart';

const String tagTable = "tag";
const String columnTagName = "name";
const String columnTagVaultId = "vault_id";
const String columnTagEntryId = "entry_id";

class Tag {
  String id;
  String name;
  String vaultId;
  String entryId;
  DateTime createdAt;
  DateTime updatedAt;
  DateTime? deletedAt;

  Tag({
    required this.id,
    required this.name,
    required this.vaultId,
    required this.entryId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  /// Transform a map of [data] into a tag
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
      entryId: data[columnTagEntryId],
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
      columnTagEntryId: entryId,
      columnTagVaultId: vaultId,
      columnCreatedAt: createdAtString,
      columnUpdatedAt: updatedAtString,
      columnDeletedAt: deletedAtString,
    };
  }
}
