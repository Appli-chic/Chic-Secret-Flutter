import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:chic_secret/model/database/custom_field.dart';
import 'package:chic_secret/model/database/entry.dart';
import 'package:chic_secret/utils/chic_platform.dart';
import 'package:chic_secret/utils/security.dart';
import 'package:chic_secret/utils/shared_data.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

import '../model/database/category.dart';
import '../service/category_service.dart';
import '../service/entry_service.dart';

class ImportData {
  final List<String> categoriesName;
  final List<Category> categories;
  final List<Entry> entries;
  final List<CustomField> customFields;

  ImportData({
    this.categoriesName = const [],
    this.categories = const [],
    this.entries = const [],
    this.customFields = const [],
  });
}

enum ImportType {
  Buttercup,
  ChicSecret,
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

  var categories = await CategoryService.getAllByVault(selectedVault!.id);
  var trashCategoryId = "";

  for (var category in categories) {
    if (!category.isTrash) {
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
    } else {
      trashCategoryId = category.id;
    }
  }

  var entries = await EntryService.getAllByVault(selectedVault!.id);

  for (var entry in entries) {
    if (trashCategoryId != entry.categoryId) {
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
  }

  String csv = const ListToCsvConverter().convert(rows);

  String? filePath = await saveFileToDocuments(
    'chic_secret_export.csv',
    Uint8List.fromList(utf8.encode(csv)),
  );

  if (filePath != null) {
    await openSafeFile(filePath);
  } else {
    print('Failed to save the file.');
  }
}

Future<String?> saveFileToDocuments(
    String fileName, Uint8List fileBytes) async {
  try {
    Directory? directory;
    if (Platform.isAndroid) {
      directory = Directory('/storage/emulated/0/Documents');
    } else if (Platform.isIOS) {
      directory = await getApplicationDocumentsDirectory();
    }

    if (directory != null) {
      String path = '${directory.path}/$fileName';

      File file = File(path);
      await file.writeAsBytes(fileBytes);

      print('File saved at: $path');
      return path;
    } else {
      throw Exception('Unable to get the documents directory.');
    }
  } catch (e) {
    print('Error saving file: $e');
    return null;
  }
}

Future<void> openSafeFile(String filePath) async {
  try {
    final File file = File(filePath);

    if (Platform.isAndroid) {
      await Permission.storage.request();
    }

    final Uri contentUri =
        Uri.parse('content://${Uri.encodeComponent(file.path)}');

    if (await canLaunchUrl(contentUri)) {
      await launchUrl(
        contentUri,
        mode: LaunchMode.externalApplication,
      );
    } else {
      throw 'Could not open file at path: $filePath';
    }
  } catch (e) {
    print('Error opening file: $e');
  }
}

Future<ImportData?> importFromFile(ImportType importType) async {
  if (ChicPlatform.isDesktop()) {
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
        case ImportType.ChicSecret:
          var lines = await file
              .openRead()
              .map(utf8.decode)
              .transform(LineSplitter())
              .toList();
          return _importFromChicSecret(lines);
      }
    }
  } else {
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
        case ImportType.ChicSecret:
          var lines = await file
              .openRead()
              .map(utf8.decode)
              .transform(LineSplitter())
              .toList();
          return _importFromChicSecret(lines);
      }
    }
  }

  return null;
}

Future<ImportData> _importFromChicSecret(List<String> lines) async {
  List<Category> categories = [];
  List<Entry> entries = [];

  var index = 0;
  for (var line in lines) {
    RegExp exp = RegExp(r'(?:,|\n|^)("(?:(?:"")*[^"]*)*"|[^",\n]*|(?:\n|$))');
    Iterable<RegExpMatch> matchesCells = exp.allMatches(line);
    List<String> cells = matchesCells.map((c) {
      return c.group(1)!;
    }).toList();

    if (index == 0) {
    } else if (cells[0].isNotEmpty) {
      var category = Category(
        id: cells[0],
        name: cells[1],
        color: cells[2],
        icon: int.parse(cells[3]),
        isTrash: false,
        vaultId: selectedVault!.id,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      categories.add(category);
    } else {
      var entry = Entry(
        id: Uuid().v4(),
        name: cells[3],
        username: cells[4],
        hash: Security.encrypt(currentPassword!, cells[5]),
        vaultId: selectedVault!.id,
        categoryId: cells[6],
        passwordSize: cells[5].length,
        comment: cells.length > 8 ? cells[7] : null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      entries.add(entry);
    }

    index++;
  }

  return ImportData(
    categories: categories,
    entries: entries,
  );
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
      for (var cell in cells.sublist(8, cells.length)) {
        customFieldKeys.add(cell);
      }
    } else {
      if (cells[0] == "group") {
        categoriesMap[cells[1]] = cells[2];
      } else {
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
    categoriesName: categoriesMap.entries.map((entry) => entry.value).toList(),
    entries: entries,
    customFields: customFields,
  );
}
