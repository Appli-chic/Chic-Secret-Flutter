import 'dart:io';

import 'package:chic_secret/component/common/chic_navigator.dart';
import 'package:chic_secret/localization/app_translations.dart';
import 'package:chic_secret/model/database/category.dart';
import 'package:chic_secret/model/database/entry.dart';
import 'package:chic_secret/provider/synchronization_provider.dart';
import 'package:chic_secret/service/entry_service.dart';
import 'package:chic_secret/feature/entry/detail/entry_detail_screen.dart';
import 'package:chic_secret/utils/chic_platform.dart';
import 'package:chic_secret/utils/security.dart';
import 'package:chic_secret/utils/shared_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EntriesScreenViewModel with ChangeNotifier {
  Function(Entry entry)? _onEntrySelected = null;

  List<Entry> entries = [];
  Entry? selectedEntry;
  List<Entry> selectedEntries = [];

  List<Entry> weakPasswordEntries = [];
  List<Entry> oldEntries = [];
  List<Entry> duplicatedEntries = [];

  final searchController = TextEditingController();

  bool isCommandKeyDown = false;
  bool isControlKeyDown = false;

  EntriesScreenViewModel(Function(Entry entry)? onEntrySelected) {
    _onEntrySelected = onEntrySelected;
    loadPassword();
  }

  loadPassword({bool isClearingSearch = true}) async {
    if (isClearingSearch) {
      searchController.clear();
    }

    if (selectedVault != null) {
      String? categoryId;
      String? tagId;

      // Check if a category is selected
      if (selectedCategory != null &&
          selectedCategory!.id.isNotEmpty &&
          ChicPlatform.isDesktop()) {
        categoryId = selectedCategory!.id;
      }

      // Check if a tag is selected
      if (selectedTag != null &&
          selectedTag!.id.isNotEmpty &&
          ChicPlatform.isDesktop()) {
        tagId = selectedTag!.id;
      }

      entries = await EntryService.getAllByVault(
        selectedVault!.id,
        categoryId: categoryId,
        tagId: tagId,
      );
    }

    await searchPassword(searchController.text);
    await _checkPasswordSecurity();
    notifyListeners();
  }

  _checkPasswordSecurity() async {
    var data = await Security.retrievePasswordsSecurityInfo();

    weakPasswordEntries = data.item1;
    oldEntries = data.item2;
    duplicatedEntries = data.item3;

    notifyListeners();
  }

  selectEntry(Entry? entry) {
    selectedEntry = entry;
    notifyListeners();
  }

  searchPassword(String text) async {
    if (selectedVault != null) {
      String? categoryId;
      String? tagId;

      // Check if a category is selected
      if (selectedCategory != null &&
          selectedCategory!.id.isNotEmpty &&
          ChicPlatform.isDesktop()) {
        categoryId = selectedCategory!.id;
      }

      // Check if a tag is selected
      if (selectedTag != null &&
          selectedTag!.id.isNotEmpty &&
          ChicPlatform.isDesktop()) {
        tagId = selectedTag!.id;
      }

      entries = await EntryService.search(
        selectedVault!.id,
        text,
        categoryId: categoryId,
        tagId: tagId,
      );

      notifyListeners();
    }
  }

  bool isDesktopEntrySelected(int index) {
    if (selectedEntries.isNotEmpty) {
      // Multi select
      return selectedEntries.contains(entries[index]);
    } else {
      // Single select
      return selectedEntry != null && selectedEntry!.id == entries[index].id;
    }
  }

  onEntrySelected(Entry entry, BuildContext context) async {
    if (isCommandKeyDown) {
      _onMultiEntrySelected(entry);
    } else {
      await _onSingleEntrySelected(entry, context);
    }
  }

  _onMultiEntrySelected(Entry entry) {
    if (!selectedEntries.contains(entry)) {
      // Select one more item
      if (selectedEntry != null) {
        selectedEntries.add(selectedEntry!);
        selectedEntry = null;
      }

      selectedEntries.add(entry);
    } else {
      // Deselect an item
      selectedEntries.remove(entry);
    }

    notifyListeners();
  }

  _onSingleEntrySelected(Entry entry, BuildContext context) async {
    selectedEntry = entry;
    selectedEntries.clear();

    if (ChicPlatform.isDesktop()) {
      if (_onEntrySelected != null) {
        _onEntrySelected!(entry);
      }
    } else {
      await ChicNavigator.push(
        context,
        EntryDetailScreen(
          entry: entry,
          previousPageTitle: AppTranslations.of(context).text("passwords"),
        ),
      );
      await loadPassword(isClearingSearch: false);
      await searchPassword(searchController.text);
    }

    notifyListeners();
  }

  onKeyChanged(RawKeyEvent event, bool isSearchFocused) {
    // Retrieve the code changing
    LogicalKeyboardKey keyCode;
    switch (event.data.runtimeType) {
      case RawKeyEventData:
        final RawKeyEventData data = event.data;
        keyCode = data.logicalKey;
        break;
      case RawKeyEventDataWindows:
        final RawKeyEventDataWindows data =
            event.data as RawKeyEventDataWindows;
        keyCode = data.logicalKey;
        break;
      case RawKeyEventDataLinux:
        final RawKeyEventDataLinux data = event.data as RawKeyEventDataLinux;
        keyCode = data.logicalKey;
        break;
      case RawKeyEventDataMacOs:
        final RawKeyEventDataMacOs data = event.data as RawKeyEventDataMacOs;
        keyCode = data.logicalKey;
        break;
      default:
        return null;
    }

    var commandKeyIsConcerned = false;
    var controlKeyIsConcerned = false;
    var aKeyIsConcerned = false;

    if (keyCode == LogicalKeyboardKey.keyA) {
      aKeyIsConcerned = true;
    }

    if (Platform.isMacOS) {
      if (keyCode == LogicalKeyboardKey.metaLeft ||
          keyCode == LogicalKeyboardKey.metaRight) {
        commandKeyIsConcerned = true;
      }

      if (keyCode == LogicalKeyboardKey.controlLeft ||
          keyCode == LogicalKeyboardKey.controlRight) {
        controlKeyIsConcerned = true;
      }
    } else {
      if (keyCode == LogicalKeyboardKey.controlLeft ||
          keyCode == LogicalKeyboardKey.controlRight) {
        commandKeyIsConcerned = true;
      }
    }

    switch (event.runtimeType) {
      case RawKeyDownEvent:
        if (commandKeyIsConcerned) {
          isCommandKeyDown = true;
        } else if (controlKeyIsConcerned) {
          isControlKeyDown = true;
        } else if (aKeyIsConcerned && isCommandKeyDown && !isSearchFocused) {
          // Select all entries
          selectedEntries.clear();
          selectedEntries.addAll(entries);
        }

        notifyListeners();
        break;
      case RawKeyUpEvent:
        if (commandKeyIsConcerned) {
          isCommandKeyDown = false;
        } else if (controlKeyIsConcerned) {
          isControlKeyDown = false;
        }

        notifyListeners();
        break;
      default:
        return null;
    }
  }

  onMovingEntriesToTrash(
    SynchronizationProvider synchronizationProvider,
    Entry entry,
    bool isAlreadyInTrash,
    bool isMultiSelected,
  ) async {
    if (isMultiSelected) {
      await _deleteManyEntries(entry, isAlreadyInTrash);
    } else {
      await _deleteOneEntry(entry, isAlreadyInTrash);
    }

    synchronizationProvider.synchronize();
    loadPassword();
  }

  _deleteManyEntries(Entry entry, bool isAlreadyInTrash) async {
    if (!isAlreadyInTrash) {
      // We move the entries to the trash bin
      List<Future<void>> futureList = [];

      for (var selectedEntry in selectedEntries) {
        futureList.add(EntryService.moveToTrash(selectedEntry));
      }

      await Future.wait(futureList);
    } else {
      // We delete them definitely
      List<Future<void>> futureList = [];

      for (var currentSelectedEntry in selectedEntries) {
        futureList.add(EntryService.deleteDefinitively(currentSelectedEntry));

        if (currentSelectedEntry == selectedEntry) {
          selectedEntry = null;

          if (_onEntrySelected != null) {
            _onEntrySelected!(entry);
          }
        }
      }

      await Future.wait(futureList);
    }
  }

  _deleteOneEntry(Entry entry, bool isAlreadyInTrash) async {
    if (!isAlreadyInTrash) {
      // We move the entry to the trash bin
      await EntryService.moveToTrash(entry);
    } else {
      // We delete it definitely
      await EntryService.deleteDefinitively(entry);

      if (entry == selectedEntry) {
        selectedEntry = null;

        if (_onEntrySelected != null) {
          _onEntrySelected!(entry);
        }
      }
    }
  }

  onMovingToCategory(
    SynchronizationProvider synchronizationProvider,
    Entry entry,
    Category category,
  ) async {
    var isMultiSelected = selectedEntries.isNotEmpty;

    if (isMultiSelected) {
      // Move multiple entries
      List<Future<void>> futureList = [];

      for (var selectedEntry in selectedEntries) {
        futureList.add(
            EntryService.moveToAnotherCategory(selectedEntry, category.id));
      }

      await Future.wait(futureList);
    } else {
      // Move one entry
      await EntryService.moveToAnotherCategory(entry, category.id);
    }

    synchronizationProvider.synchronize();
    loadPassword();
  }
}
