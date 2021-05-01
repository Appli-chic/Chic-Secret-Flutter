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

  /// Transform a json to a custom field
  factory CustomField.fromJson(Map<String, dynamic> json) {
    var createdAtString = DateTime.parse(json['CreatedAt']);
    var updatedAtString = DateTime.parse(json['UpdatedAt']);
    var deletedAtString;

    if (json['DeletedAt'] != null) {
      deletedAtString = DateTime.parse(json['DeletedAt']);
    }

    return CustomField(
      id: json['ID'],
      name: json['Name'],
      value: json['Value'],
      entryId: json['EntryID'],
      createdAt: createdAtString,
      updatedAt: updatedAtString,
      deletedAt: deletedAtString,
    );
  }

  /// Transform a custom field to a json
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
    data['Value'] = value;
    data['EntryID'] = entryId;
    data['CreatedAt'] = createdAtString;
    data['UpdatedAt'] = updatedAtString;
    data['DeletedAt'] = deletedAtString;
    return data;
  }

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
