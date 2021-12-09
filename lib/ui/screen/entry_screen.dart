import 'dart:io';
import 'dart:math';

import 'package:chic_secret/localization/app_translations.dart';
import 'package:chic_secret/model/database/category.dart';
import 'package:chic_secret/model/database/entry.dart';
import 'package:chic_secret/provider/synchronization_provider.dart';
import 'package:chic_secret/provider/theme_provider.dart';
import 'package:chic_secret/service/entry_service.dart';
import 'package:chic_secret/ui/component/common/chic_navigator.dart';
import 'package:chic_secret/ui/component/common/chic_text_button.dart';
import 'package:chic_secret/ui/component/common/chic_text_field.dart';
import 'package:chic_secret/ui/component/common/chic_text_icon_button.dart';
import 'package:chic_secret/ui/component/entry_item.dart';
import 'package:chic_secret/ui/screen/entry_detail_screen.dart';
import 'package:chic_secret/ui/screen/new_entry_screen.dart';
import 'package:chic_secret/ui/screen/select_category_screen.dart';
import 'package:chic_secret/ui/screen/vaults_screen.dart';
import 'package:chic_secret/utils/chic_platform.dart';
import 'package:chic_secret/utils/security.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class EntryScreenController {
  void Function({bool isClearingSearch})? reloadPasswords;
  void Function(Entry?)? selectEntry;

  EntryScreenController({
    this.reloadPasswords,
    this.selectEntry,
  });
}

class EntryScreen extends StatefulWidget {
  final EntryScreenController? passwordScreenController;
  final Function()? reloadCategories;
  final Function()? reloadTags;
  final Function(Entry entry)? onEntrySelected;
  final Function()? onCreateNewEntry;

  const EntryScreen({
    this.passwordScreenController,
    this.reloadCategories,
    this.reloadTags,
    this.onEntrySelected,
    this.onCreateNewEntry,
  });

  @override
  _EntryScreenState createState() => _EntryScreenState();
}

class _EntryScreenState extends State<EntryScreen>
    with AutomaticKeepAliveClientMixin<EntryScreen> {
  late SynchronizationProvider _synchronizationProvider;

  List<Entry> _entries = [];
  Entry? _selectedEntry;
  List<Entry> _selectedEntries = [];

  List<Entry> _weakPasswordEntries = [];
  List<Entry> _oldEntries = [];
  List<Entry> _duplicatedEntries = [];

  final _searchController = TextEditingController();
  FocusNode _searchFocusNode = FocusNode();
  FocusNode _desktopSearchFocusNode = FocusNode();
  FocusNode _shortcutsFocusNode = FocusNode();
  bool _isCommandKeyDown = false;
  bool _isControlKeyDown = false;

  ScrollController _desktopScrollController = ScrollController();
  final int _extraScrollSpeed = 80;

  @override
  void initState() {
    _desktopScrollController.addListener(() {
      ScrollDirection scrollDirection =
          _desktopScrollController.position.userScrollDirection;
      if (scrollDirection != ScrollDirection.idle) {
        double scrollEnd = _desktopScrollController.offset +
            (scrollDirection == ScrollDirection.reverse
                ? _extraScrollSpeed
                : -_extraScrollSpeed);
        scrollEnd = min(_desktopScrollController.position.maxScrollExtent,
            max(_desktopScrollController.position.minScrollExtent, scrollEnd));
        _desktopScrollController.jumpTo(scrollEnd);
      }
    });

    if (widget.passwordScreenController != null) {
      widget.passwordScreenController!.reloadPasswords = _loadPassword;
      widget.passwordScreenController!.selectEntry = _selectEntry;
    }

    _loadPassword();

    super.initState();
  }

  /// Triggered when we ask to select an entry
  _selectEntry(Entry? entry) {
    _selectedEntry = entry;
    setState(() {});
  }

  /// Load the list of passwords linked to the current vault
  _loadPassword({bool isClearingSearch = true}) async {
    if (isClearingSearch) {
      _searchController.clear();
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

      _entries = await EntryService.getAllByVault(
        selectedVault!.id,
        categoryId: categoryId,
        tagId: tagId,
      );
    }

    await _searchPassword(_searchController.text);
    _checkPasswordSecurity();
  }

  /// Search the entries that have a field containing the text
  _searchPassword(String text) async {
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

      _entries = await EntryService.search(
        selectedVault!.id,
        text,
        categoryId: categoryId,
        tagId: tagId,
      );

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var themeProvider = Provider.of<ThemeProvider>(context, listen: true);
    _synchronizationProvider =
        Provider.of<SynchronizationProvider>(context, listen: true);

    return RawKeyboardListener(
      autofocus: true,
      focusNode: _shortcutsFocusNode,
      onKey: _onKeyChanged,
      child: Scaffold(
        backgroundColor: themeProvider.backgroundColor,
        appBar: _displaysAppbar(themeProvider),
        body: _displayBody(themeProvider),
      ),
    );
  }

  /// Displays the appbar that is only appearing on the mobile version
  PreferredSizeWidget? _displaysAppbar(ThemeProvider themeProvider) {
    if (!ChicPlatform.isDesktop()) {
      return AppBar(
        backgroundColor: themeProvider.secondBackgroundColor,
        title: Text(AppTranslations.of(context).text("passwords")),
        actions: [
          IconButton(
            icon: Icon(
              Icons.add,
              color: themeProvider.textColor,
            ),
            onPressed: _onAddEntryClicked,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60.0),
          child: Row(
            children: [
              Expanded(
                child: _displaySearchBar(themeProvider),
              ),
              _searchController.text.isNotEmpty
                  ? ChicTextButton(
                      child: Text(AppTranslations.of(context).text("cancel")),
                      onPressed: () {
                        _searchController.clear();
                        FocusScope.of(context).requestFocus(FocusNode());
                        _searchPassword("");
                      },
                    )
                  : SizedBox.shrink(),
            ],
          ),
        ),
      );
    } else {
      return null;
    }
  }

  /// Displays the body of the screen for both Mobile and Desktop version
  Widget _displayBody(ThemeProvider themeProvider) {
    if (selectedVault == null) {
      return SizedBox.shrink();
    }

    if (ChicPlatform.isDesktop()) {
      return Column(
        children: [
          Container(
            margin: EdgeInsets.only(left: 16, top: 16, right: 16, bottom: 8),
            child: _displaySearchBar(themeProvider),
          ),
          Expanded(
            child: ListView.builder(
              controller: _desktopScrollController,
              itemCount: _entries.length,
              itemBuilder: (context, index) {
                return EntryItem(
                  entry: _entries[index],
                  isSelected: _isDesktopEntrySelected(index),
                  onTap: _onEntrySelected,
                  onMovingEntryToTrash: _onMovingEntryToTrash,
                  onMovingToCategory: _onMovingToCategory,
                  isControlKeyDown: _isControlKeyDown,
                  isWeakPassword: _weakPasswordEntries
                      .where((e) => e.id == _entries[index].id)
                      .isNotEmpty,
                  isOldPassword: _oldEntries
                      .where((e) => e.id == _entries[index].id)
                      .isNotEmpty,
                  isDuplicatedPassword: _duplicatedEntries
                      .where((e) => e.id == _entries[index].id)
                      .isNotEmpty,
                );
              },
            ),
          ),
          Container(
            width: double.infinity,
            margin: EdgeInsets.only(bottom: 8, top: 10, left: 16, right: 16),
            child: ChicTextIconButton(
              onPressed: _onAddEntryClicked,
              icon: Icon(
                Icons.add,
                color: themeProvider.textColor,
                size: 20,
              ),
              label: Text(
                AppTranslations.of(context).text("new_password"),
                style: TextStyle(color: themeProvider.textColor),
              ),
              backgroundColor: themeProvider.selectionBackground,
              padding: EdgeInsets.only(top: 10, bottom: 10),
            ),
          ),
        ],
      );
    }

    return Container(
      margin: EdgeInsets.only(bottom: 8),
      child: ListView.builder(
        physics: BouncingScrollPhysics(),
        itemCount: _entries.length,
        itemBuilder: (context, index) {
          return EntryItem(
            entry: _entries[index],
            isSelected: false,
            isWeakPassword: _weakPasswordEntries
                .where((e) => e.id == _entries[index].id)
                .isNotEmpty,
            isOldPassword:
                _oldEntries.where((e) => e.id == _entries[index].id).isNotEmpty,
            isDuplicatedPassword: _duplicatedEntries
                .where((e) => e.id == _entries[index].id)
                .isNotEmpty,
            onTap: _onEntrySelected,
          );
        },
      ),
    );
  }

  /// Displays the search bar for both mobile and desktop
  Widget _displaySearchBar(ThemeProvider themeProvider) {
    return ChicTextField(
      controller: _searchController,
      hint: AppTranslations.of(context).text("search_passwords"),
      desktopFocus: _desktopSearchFocusNode,
      focus: _searchFocusNode,
      type: ChicTextFieldType.filledRounded,
      prefix: Container(
        margin: EdgeInsets.only(left: 8, right: 8),
        child: Icon(
          Icons.search,
          color: themeProvider.placeholder,
        ),
      ),
      suffix: _searchController.text.isNotEmpty
          ? Container(
              margin: EdgeInsets.only(right: 4),
              child: IconButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                hoverColor: Colors.transparent,
                iconSize: 16,
                icon: Icon(
                  Icons.clear,
                  color: themeProvider.secondTextColor,
                ),
                onPressed: () {
                  _searchController.clear();
                  FocusScope.of(context).requestFocus(new FocusNode());
                  _searchPassword("");
                },
              ),
            )
          : null,
      onTextChanged: (String text) {
        _searchPassword(text);
      },
    );
  }

  /// Returns for the desktop if the entry is selected or not
  /// depending of the single or multi select
  bool _isDesktopEntrySelected(int index) {
    if (_selectedEntries.isNotEmpty) {
      // Multi select
      return _selectedEntries.contains(_entries[index]);
    } else {
      // Single select
      return _selectedEntry != null && _selectedEntry!.id == _entries[index].id;
    }
  }

  /// When the entry is selected by the user, it will display the user screen
  _onEntrySelected(Entry entry) async {
    if (_isCommandKeyDown) {
      // If it's a mutli select
      if (!_selectedEntries.contains(entry)) {
        // Select one more item
        if (_selectedEntry != null) {
          _selectedEntries.add(_selectedEntry!);
          _selectedEntry = null;
        }

        _selectedEntries.add(entry);
      } else {
        // Deselect an item
        _selectedEntries.remove(entry);
      }

      setState(() {});
    } else {
      // If the user do a single select
      _selectedEntry = entry;
      _selectedEntries.clear();

      if (ChicPlatform.isDesktop()) {
        if (widget.onEntrySelected != null) {
          widget.onEntrySelected!(entry);
        }
      } else {
        await ChicNavigator.push(context, EntryDetailScreen(entry: entry));
        await _loadPassword(isClearingSearch: false);
        await _searchPassword(_searchController.text);
      }

      setState(() {});
    }
  }

  /// Call the [NewEntryScreen] screen to create a new entry
  _onAddEntryClicked() async {
    var data;

    if (ChicPlatform.isDesktop()) {
      // Display the NewEntryScreen in the entry detail
      _searchFocusNode.unfocus();
      FocusScope.of(context).unfocus();
      _shortcutsFocusNode.requestFocus();
      if (widget.onCreateNewEntry != null) {
        widget.onCreateNewEntry!();
      }
    } else {
      // Push a new screen if it's on mobile
      data = await ChicNavigator.push(
        context,
        NewEntryScreen(),
      );
    }

    if (data != null) {
      _loadPassword();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _desktopSearchFocusNode.dispose();
    _shortcutsFocusNode.dispose();

    super.dispose();
  }

  /// Check when a key is pressed and released to select different entries
  _onKeyChanged(RawKeyEvent event) {
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

    // Check the key changed
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
          _isCommandKeyDown = true;
        } else if (controlKeyIsConcerned) {
          _isControlKeyDown = true;
        } else if (aKeyIsConcerned &&
            _isCommandKeyDown &&
            !_searchFocusNode.hasFocus) {
          // Select all entries
          _selectedEntries.clear();
          _selectedEntries.addAll(_entries);
        }

        setState(() {});
        break;
      case RawKeyUpEvent:
        if (commandKeyIsConcerned) {
          _isCommandKeyDown = false;
        } else if (controlKeyIsConcerned) {
          _isControlKeyDown = false;
        }

        setState(() {});
        break;
      default:
        return null;
    }
  }

  /// Ask if the entry should be move to the trash
  /// Move to the trash a selection of entry if many or selected
  _onMovingEntryToTrash(Entry entry) async {
    var isAlreadyInTrash = entry.category!.isTrash;
    var isMultiSelected = _selectedEntries.isNotEmpty;
    var errorMessage = AppTranslations.of(context)
        .textWithArgument("warning_message_delete_entry", entry.name);

    if (isMultiSelected) {
      // Move multiple entries to trash
      if (isAlreadyInTrash) {
        errorMessage = AppTranslations.of(context)
            .text("warning_message_delete_multiple_entry_definitely");
      } else {
        errorMessage = AppTranslations.of(context)
            .text("warning_message_delete_multiple_entry");
      }
    } else {
      // Single entry to move to trash
      if (isAlreadyInTrash) {
        errorMessage = AppTranslations.of(context).textWithArgument(
            "warning_message_delete_entry_definitely", entry.name);
      }
    }

    var result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppTranslations.of(context).text("warning")),
          content: Text(errorMessage),
          actions: [
            TextButton(
              child: Text(
                AppTranslations.of(context).text("cancel"),
              ),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text(
                AppTranslations.of(context).text("delete"),
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (result != null && result) {
      if (isMultiSelected) {
        // Delete many entries
        if (!isAlreadyInTrash) {
          // We move the entries to the trash bin
          List<Future<void>> futureList = [];

          for (var selectedEntry in _selectedEntries) {
            futureList.add(EntryService.moveToTrash(selectedEntry));
          }

          await Future.wait(futureList);
        } else {
          // We delete them definitely
          List<Future<void>> futureList = [];

          for (var selectedEntry in _selectedEntries) {
            futureList.add(EntryService.deleteDefinitively(selectedEntry));

            if (selectedEntry == _selectedEntry) {
              _selectedEntry = null;

              if (widget.onEntrySelected != null) {
                widget.onEntrySelected!(entry);
              }
            }
          }

          await Future.wait(futureList);
        }
      } else {
        // Delete one Entry
        if (!isAlreadyInTrash) {
          // We move the entry to the trash bin
          await EntryService.moveToTrash(entry);
        } else {
          // We delete it definitely
          await EntryService.deleteDefinitively(entry);

          if (entry == _selectedEntry) {
            _selectedEntry = null;

            if (widget.onEntrySelected != null) {
              widget.onEntrySelected!(entry);
            }
          }
        }
      }

      _synchronizationProvider.synchronize();
      _loadPassword();
    }
  }

  /// Call the [SelectCategoryScreen] to move to a new category
  /// Move to a selection of entry if many or selected
  _onMovingToCategory(Entry entry) async {
    var isMultiSelected = _selectedEntries.isNotEmpty;

    var category = await ChicNavigator.push(
      context,
      SelectCategoryScreen(),
      isModal: true,
    );

    if (category != null && category is Category) {
      if (isMultiSelected) {
        // Move multiple entries
        List<Future<void>> futureList = [];

        for (var selectedEntry in _selectedEntries) {
          futureList.add(
              EntryService.moveToAnotherCategory(selectedEntry, category.id));
        }

        await Future.wait(futureList);
      } else {
        // Move one entry
        await EntryService.moveToAnotherCategory(entry, category.id);
      }

      _synchronizationProvider.synchronize();
      _loadPassword();
    }
  }

  /// Check the security of all the entries
  _checkPasswordSecurity() async {
    var data = await Security.retrievePasswordsSecurityInfo();

    _weakPasswordEntries = data.item1;
    _oldEntries = data.item2;
    _duplicatedEntries = data.item3;

    setState(() {});
  }

  @override
  bool get wantKeepAlive => true;
}
