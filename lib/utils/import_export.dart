import 'dart:collection';
import 'dart:convert';

import 'package:chic_secret/model/database/custom_field.dart';
import 'package:chic_secret/model/database/entry.dart';
import 'package:chic_secret/ui/screen/vaults_screen.dart';
import 'package:file_selector/file_selector.dart';
import 'package:uuid/uuid.dart';

class ImportData {
  final List<String> categories;
  final List<Entry> entries;
  final List<CustomField> customFields;

  ImportData({
    this.categories = const [],
    this.entries = const [],
    this.customFields = const [],
  });
}

enum ImportType {
  Buttercup,
}

/// Import a file from the type of import
Future<ImportData> importFromFile(ImportType importType) async {
  final typeGroup = XTypeGroup(label: 'CSV', extensions: ['csv']);
  final file = await openFile(acceptedTypeGroups: [typeGroup]);

  if (file != null) {
    switch (importType) {
      case ImportType.Buttercup:
        return _importFromButtercup(file);
      default:
        break;
    }
  }

  return ImportData();
}

/// Import the buttercup data
Future<ImportData> _importFromButtercup(XFile file) async {
  var index = 0;
  var lines =
      await file.openRead().map(utf8.decode).transform(LineSplitter()).toList();

  List<String> customFieldKeys = [];
  HashMap<String, String> categoriesMap = HashMap();
  List<Entry> entries = [];
  List<CustomField> customFields = [];

  for (var line in lines) {
    RegExp exp = RegExp(r'(?:,|\n|^)("(?:(?:"")*[^"]*)*"|[^",\n]*|(?:\n|$))');
    Iterable<RegExpMatch> matchesCells = exp.allMatches(line);
    List<String> cells = matchesCells.map((c) {
      return c.group(1)!;
    }).toList();

    if (index == 0) {
      // Retrieve the custom fields
      for (var cell in cells.sublist(8, cells.length)) {
        customFieldKeys.add(cell);
      }
    } else {
      if (cells[0] == "group") {
        // Retrieve categories
        categoriesMap[cells[1]] = cells[2];
      } else {
        // Retrieve the passwords
        var hash = cells[6];
        if (hash.contains(",")) {
          hash = hash.substring(1, hash.length - 1);
        }

        var entry = Entry(
          id: Uuid().v4(),
          name: cells[4],
          username: cells[5],
          hash: hash,
          vaultId: selectedVault!.id,
          categoryId: categoriesMap[cells[1]]!,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        entries.add(entry);

        // Add custom fields
        var customFieldsCells = cells.sublist(8, cells.length);
        for (var cell in customFieldsCells) {
          if (cell.isNotEmpty) {
            var customField = CustomField(
              id: Uuid().v4(),
              name: customFieldKeys[customFieldsCells.indexOf(cell)],
              value: cell,
              entryId: entry.id,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );

            customFields.add(customField);
          }
        }
      }
    }

    index++;
  }

  return ImportData(
    categories: categoriesMap.entries.map((entry) => entry.value).toList(),
    entries: entries,
    customFields: customFields,
  );
}
