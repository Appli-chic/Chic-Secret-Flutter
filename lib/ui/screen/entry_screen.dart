import 'dart:io';

import 'package:chic_secret/localization/app_translations.dart';
import 'package:chic_secret/model/database/entry.dart';
import 'package:chic_secret/provider/theme_provider.dart';
import 'package:chic_secret/service/entry_service.dart';
import 'package:chic_secret/ui/component/common/chic_navigator.dart';
import 'package:chic_secret/ui/component/common/chic_text_button.dart';
import 'package:chic_secret/ui/component/common/chic_text_field.dart';
import 'package:chic_secret/ui/component/common/chic_text_icon_button.dart';
import 'package:chic_secret/ui/component/entry_item.dart';
import 'package:chic_secret/ui/screen/entry_detail_screen.dart';
import 'package:chic_secret/ui/screen/new_entry_screen.dart';
import 'package:chic_secret/ui/screen/vaults_screen.dart';
import 'package:chic_secret/utils/chic_platform.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class EntryScreenController {
  void Function()? reloadPasswords;
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

class _EntryScreenState extends State<EntryScreen> {
  List<Entry> _entries = [];
  Entry? _selectedEntry;
  List<Entry> _selectedEntries = [];

  final _searchController = TextEditingController();
  var _searchFocusNode = FocusNode();
  var _desktopSearchFocusNode = FocusNode();
  var _isControlKeyDown = false;

  @override
  void initState() {
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
  _loadPassword() async {
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
      setState(() {});
    }
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
    var themeProvider = Provider.of<ThemeProvider>(context, listen: true);

    return RawKeyboardListener(
      autofocus: true,
      focusNode: FocusNode(),
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
        brightness: themeProvider.getBrightness(),
        title: Text(AppTranslations.of(context).text("passwords")),
        actions: [
          IconButton(
            icon: Icon(
              Icons.add,
              color: themeProvider.textColor,
            ),
            onPressed: _onAddEntryClicked,
          )
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
              itemCount: _entries.length,
              itemBuilder: (context, index) {
                return EntryItem(
                  entry: _entries[index],
                  isSelected: _isDesktopEntrySelected(index),
                  onTap: _onEntrySelected,
                  onEntryChanged: () {
                    _loadPassword();
                  },
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

    return ListView.builder(
      physics: BouncingScrollPhysics(),
      itemCount: _entries.length,
      itemBuilder: (context, index) {
        return EntryItem(
          entry: _entries[index],
          isSelected: false,
          onTap: _onEntrySelected,
        );
      },
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
    if (_isControlKeyDown) {
      // If it's a mutli select
      _selectedEntry = null;
      _selectedEntries.add(entry);
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
        _loadPassword();
      }

      setState(() {});
    }
  }

  /// Call the [NewEntryScreen] screen to create a new entry
  _onAddEntryClicked() async {
    var data;

    if (ChicPlatform.isDesktop()) {
      // Display the NewEntryScreen in the entry detail
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
    var ctrlKeyIsConcerned = false;
    if (Platform.isMacOS) {
      if (keyCode == LogicalKeyboardKey.metaLeft ||
          keyCode == LogicalKeyboardKey.metaRight) {
        ctrlKeyIsConcerned = true;
      }
    } else {
      if (keyCode == LogicalKeyboardKey.controlLeft ||
          keyCode == LogicalKeyboardKey.controlRight) {
        ctrlKeyIsConcerned = true;
      }
    }

    // Check the pressing state
    if (ctrlKeyIsConcerned) {
      switch (event.runtimeType) {
        case RawKeyDownEvent:
          _isControlKeyDown = true;
          setState(() {});
          break;
        case RawKeyUpEvent:
          _isControlKeyDown = false;
          setState(() {});
          break;
        default:
          return null;
      }
    }
  }
}
