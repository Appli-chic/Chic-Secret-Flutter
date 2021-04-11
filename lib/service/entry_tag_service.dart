import 'package:chic_secret/model/database/entry_tag.dart';
import 'package:chic_secret/utils/database.dart';

class EntryTagService {
  /// Save a [tag] into the local database
  static Future<void> save(EntryTag entryTag) async {
    await db.insert(
      entryTagTable,
      entryTag.toMap(),
    );
  }
}