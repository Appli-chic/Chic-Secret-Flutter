import 'package:chic_secret/utils/database_structure.dart';
import 'package:intl/intl.dart';

const String entryTagTable = "entry_tag";
const String columnEntryTagEntryId = "entry_id";
const String columnEntryTagTagId = "tag_id";

class EntryTag {
  String entryId;
  String tagId;
  DateTime createdAt;
  DateTime updatedAt;
  DateTime? deletedAt;

  EntryTag({
    required this.entryId,
    required this.tagId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  /// Transform a map of [data] into a entry tag
  factory EntryTag.fromMap(Map<String, dynamic> data) {
    var createdAtString = DateTime.parse(data[columnCreatedAt]);
    var updatedAtString = DateTime.parse(data[columnUpdatedAt]);
    var deletedAtString;

    if (data[columnDeletedAt] != null) {
      deletedAtString = DateTime.parse(data[columnDeletedAt]);
    }

    return EntryTag(
      entryId: data[columnEntryTagEntryId],
      tagId: data[columnEntryTagTagId],
      createdAt: createdAtString,
      updatedAt: updatedAtString,
      deletedAt: deletedAtString,
    );
  }

  /// Transform an entry tag into a map of data
  Map<String, dynamic> toMap() {
    var dateFormatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    String createdAtString = dateFormatter.format(createdAt);
    String updatedAtString = dateFormatter.format(updatedAt);
    String? deletedAtString;

    if (this.deletedAt != null) {
      deletedAtString = dateFormatter.format(deletedAt!);
    }

    return {
      columnEntryTagEntryId: entryId,
      columnEntryTagTagId: tagId,
      columnCreatedAt: createdAtString,
      columnUpdatedAt: updatedAtString,
      columnDeletedAt: deletedAtString,
    };
  }
}