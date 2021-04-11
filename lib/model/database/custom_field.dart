import 'package:chic_secret/utils/database_structure.dart';
import 'package:intl/intl.dart';

const String customFieldTable = "custom_field";
const String columnCustomFieldName = "name";
const String columnCustomFieldValue = "value";
const String columnCustomFieldEntryId = "entry_id";

class CustomField {
  String id;
  String name;
  String value;
  String entryId;
  DateTime createdAt;
  DateTime updatedAt;
  DateTime? deletedAt;

  CustomField({
    required this.id,
    required this.name,
    required this.value,
    required this.entryId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  /// Transform a map of [data] into a custom field
  factory CustomField.fromMap(Map<String, dynamic> data) {
    var createdAtString = DateTime.parse(data[columnCreatedAt]);
    var updatedAtString = DateTime.parse(data[columnUpdatedAt]);
    var deletedAtString;

    if (data[columnDeletedAt] != null) {
      deletedAtString = DateTime.parse(data[columnDeletedAt]);
    }

    return CustomField(
      id: data[columnId],
      name: data[columnCustomFieldName],
      value: data[columnCustomFieldValue],
      entryId: data[columnCustomFieldEntryId],
      createdAt: createdAtString,
      updatedAt: updatedAtString,
      deletedAt: deletedAtString,
    );
  }

  /// Transform a custom field into a map of data
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
      columnCustomFieldName: name,
      columnCustomFieldValue: value,
      columnCustomFieldEntryId: entryId,
      columnCreatedAt: createdAtString,
      columnUpdatedAt: updatedAtString,
      columnDeletedAt: deletedAtString,
    };
  }
}
