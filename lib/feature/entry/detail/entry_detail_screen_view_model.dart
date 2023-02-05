import 'package:chic_secret/component/entry_detail_input.dart';
import 'package:chic_secret/model/database/custom_field.dart';
import 'package:chic_secret/model/database/entry.dart';
import 'package:chic_secret/model/database/tag.dart';
import 'package:chic_secret/service/custom_field_service.dart';
import 'package:chic_secret/service/entry_service.dart';
import 'package:chic_secret/service/tag_service.dart';
import 'package:chic_secret/utils/chic_platform.dart';
import 'package:chic_secret/utils/shared_data.dart';
import 'package:flutter/material.dart';

class EntryDetailScreenViewModel with ChangeNotifier {
  List<Entry> duplicatedEntries = [];

  late Entry currentEntry;
  late Function()? onEntryDeleted;
  List<Tag> tags = [];
  List<CustomField> customFields = [];
  EntryDetailInputController passwordEntryDetailController =
      EntryDetailInputController();

  EntryDetailScreenViewModel(Entry entry, Function()? onEntryDeleted) {
    this.onEntryDeleted = onEntryDeleted;
    reload(entry);
  }

  reload(Entry entry) {
    this.currentEntry = entry;

    checkPasswordSecurity();
    loadTags();
    loadCustomFields();
  }

  checkPasswordSecurity() async {
    var entries = await EntryService.findDuplicatedPasswords(
        selectedVault!.id, currentEntry.hash);

    duplicatedEntries =
        entries.where((entry) => entry.id != currentEntry.id).toList();

    notifyListeners();
  }

  loadTags() async {
    tags = await TagService.getAllByEntry(currentEntry.id);
    notifyListeners();
  }

  loadCustomFields() async {
    customFields = await CustomFieldService.getAllByEntry(currentEntry.id);
    notifyListeners();
  }

  onDeleteEntry(BuildContext context, bool isAlreadyInTrash) async {
    if (!isAlreadyInTrash) {
      // We move the entry to the trash bin
      await EntryService.moveToTrash(currentEntry);
    } else {
      // We delete it definitely
      await EntryService.deleteDefinitively(currentEntry);
    }

    if (ChicPlatform.isDesktop()) {
      if (onEntryDeleted != null) {
        onEntryDeleted!();
      }
    } else {
      Navigator.pop(context);
    }
  }
}
