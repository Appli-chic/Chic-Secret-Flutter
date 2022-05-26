import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:chic_secret/model/database/custom_field.dart';
import 'package:chic_secret/model/database/entry.dart';
import 'package:chic_secret/ui/screen/vaults_screen.dart';
import 'package:chic_secret/utils/chic_platform.dart';
import 'package:chic_secret/utils/security.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_selector/file_selector.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

import '../service/category_service.dart';
import '../service/entry_service.dart';

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

Future<void> exportVaultData() async {
  if (Platform.isIOS || Platform.isAndroid) {
    bool status = await Permission.storage.isGranted;
    if (!status) await Permission.storage.request();
  }

  List<List<dynamic>> rows = [];
  List<dynamic> referenceRow = [];
  referenceRow.add("category_id");
  referenceRow.add("category_name");
  referenceRow.add("category_color");
  referenceRow.add("category_icon");
  referenceRow.add("entry_name");
  referenceRow.add("entry_username_email");
  referenceRow.add("entry_password");
  referenceRow.add("entry_category");
  referenceRow.add("entry_comment");
  rows.add(referenceRow);

  // Add categories
  var categories = await CategoryService.getAllByVault(selectedVault!.id);

  for(var category in categories) {
    if(!category.isTrash) {
      List<dynamic> row = [];
      row.add(category.id);
      row.add(category.name);
      row.add(category.color);
      row.add(category.icon);
      row.add("");
      row.add("");
      row.add("");
      row.add("");
      row.add("");
      rows.add(row);
    }
  }

  // Add entries
  var entries = await EntryService.getAllByVault(selectedVault!.id);

  for(var entry in entries) {
    List<dynamic> row = [];
    row.add("");
    row.add("");
    row.add("");
    row.add("");
    row.add(entry.name);
    row.add(entry.username);
    row.add(Security.decrypt(currentPassword!, entry.hash));
    row.add(entry.categoryId);
    row.add(entry.comment);
    rows.add(row);
  }

  String csv = const ListToCsvConverter().convert(rows);

  var path = await FileSaver.instance.saveFile(
    "chic_secret_export",
    Uint8List.fromList(csv.codeUnits),
    "csv",
    mimeType: MimeType.CSV,
  );

  OpenFile.open(path);
}

Future<ImportData?> importFromFile(ImportType importType) async {
  if (ChicPlatform.isDesktop()) {
    // Import on desktop
    final typeGroup = XTypeGroup(label: 'CSV', extensions: ['csv']);
    final file = await openFile(acceptedTypeGroups: [typeGroup]);

    if (file != null) {
      switch (importType) {
        case ImportType.Buttercup:
          var lines = await file
              .openRead()
              .map(utf8.decode)
              .transform(LineSplitter())
              .toList();
          return _importFromButtercup(lines);
        default:
          break;
      }
    }
  } else {
    // Import on mobile
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.single.path != null) {
      File file = File(result.files.single.path!);

      switch (importType) {
        case ImportType.Buttercup:
          var lines = await file
              .openRead()
              .map(utf8.decode)
              .transform(LineSplitter())
              .toList();
          return _importFromButtercup(lines);
        default:
          break;
      }
    }
  }

  return null;
}

Future<ImportData> _importFromButtercup(List<String> lines) async {
  var index = 0;

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
          passwordSize: hash.length,
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
