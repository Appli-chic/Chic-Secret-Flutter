import 'dart:io';
import 'dart:math';

import 'package:chic_secret/component/common/chic_elevated_button.dart';
import 'package:chic_secret/component/common/chic_navigator.dart';
import 'package:chic_secret/component/common/chic_text_button.dart';
import 'package:chic_secret/component/common/chic_text_field.dart';
import 'package:chic_secret/component/common/chic_text_icon_button.dart';
import 'package:chic_secret/component/entry_item.dart';
import 'package:chic_secret/localization/app_translations.dart';
import 'package:chic_secret/model/database/category.dart';
import 'package:chic_secret/model/database/entry.dart';
import 'package:chic_secret/provider/synchronization_provider.dart';
import 'package:chic_secret/provider/theme_provider.dart';
import 'package:chic_secret/service/entry_service.dart';
import 'package:chic_secret/ui/screen/entry_detail_screen.dart';
import 'package:chic_secret/ui/screen/new_entry_screen.dart';
import 'package:chic_secret/feature/category/select_category/select_category_screen.dart';
import 'package:chic_secret/utils/chic_platform.dart';
import 'package:chic_secret/utils/security.dart';
import 'package:chic_secret/utils/shared_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
    with AutomaticKeepAliveClientMixin<EntryScreen>, TickerProviderStateMixin {
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

  late final AnimationController _animationSlideController =
      AnimationController(
    duration: const Duration(milliseconds: 300),
    vsync: this,
  );

  late final Animation<Offset> _offsetSlideAnimation = Tween<Offset>(
    begin: const Offset(1.5, 0.0),
    end: Offset.zero,
  ).animate(CurvedAnimation(
    parent: _animationSlideController,
    curve: Curves.easeIn,
  ));

  late final AnimationController _animationOpacityController =
      AnimationController(
    duration: const Duration(milliseconds: 500),
    vsync: this,
  );

  @override
  void initState() {
    if (!Platform.isMacOS) {
      _desktopScrollController.addListener(() {
        ScrollDirection scrollDirection =
            _desktopScrollController.position.userScrollDirection;
        if (scrollDirection != ScrollDirection.idle) {
          double scrollEnd = _desktopScrollController.offset +
              (scrollDirection == ScrollDirection.reverse
                  ? _extraScrollSpeed
                  : -_extraScrollSpeed);
          scrollEnd = min(
              _desktopScrollController.position.maxScrollExtent,
              max(_desktopScrollController.position.minScrollExtent,
                  scrollEnd));
          _desktopScrollController.jumpTo(scrollEnd);
        }
      });

      _animationOpacityController.forward();
      _animationSlideController.forward();
    }

    if (widget.passwordScreenController != null) {
      widget.passwordScreenController!.reloadPasswords = _loadPassword;
      widget.passwordScreenController!.selectEntry = _selectEntry;
    }

    _loadPassword();

    super.initState();
  }

  _selectEntry(Entry? entry) {
    _selectedEntry = entry;
    setState(() {});
  }

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
    _animationOpacityController.reset();
    _animationOpacityController.forward();
    _animationSlideController.reset();
    _animationSlideController.forward();
  }

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
      child: _displayScaffold(themeProvider),
    );
  }

  Widget _displayScaffold(ThemeProvider themeProvider) {
    if (Platform.isIOS) {
      return CupertinoPageScaffold(
        backgroundColor: themeProvider.backgroundColor,
        navigationBar: _displaysIosAppbar(themeProvider),
        child: _displayBody(themeProvider),
      );
    } else {
      return Scaffold(
        backgroundColor: themeProvider.backgroundColor,
        appBar: _displaysAppbar(themeProvider),
        body: _displayBody(themeProvider),
      );
    }
  }

  ObstructingPreferredSizeWidget _displaysIosAppbar(
      ThemeProvider themeProvider) {
    return CupertinoNavigationBar(
      previousPageTitle: AppTranslations.of(context).text("vaults"),
      backgroundColor: themeProvider.secondBackgroundColor,
      middle: Text(AppTranslations.of(context).text("passwords")),
      trailing: CupertinoButton(
        padding: EdgeInsets.zero,
        alignment: Alignment.centerRight,
        child: Icon(CupertinoIcons.add),
        onPressed: _onAddEntryClicked,
      ),
    );
  }

  PreferredSizeWidget? _displaysAppbar(ThemeProvider themeProvider) {
    if (!ChicPlatform.isDesktop()) {
      return AppBar(
        backgroundColor: themeProvider.secondBackgroundColor,
        title: Text(AppTranslations.of(context).text("passwords")),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60.0),
          child: Row(
            children: [
              Expanded(
                child: _displaySearchBar(themeProvider),
              ),
              _searchFocusNode.hasFocus
                  ? Container(
                      padding: EdgeInsets.only(right: 8),
                      child: ChicTextButton(
                        child: Text(AppTranslations.of(context).text("cancel")),
                        onPressed: () {
                          _searchController.clear();
                          FocusScope.of(context).requestFocus(FocusNode());
                          _searchPassword("");
                        },
                      ),
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

  Widget _displayBody(ThemeProvider themeProvider) {
    if (selectedVault == null) {
      return SizedBox.shrink();
    }

    if (ChicPlatform.isDesktop()) {
      return _displayDesktopBody(themeProvider);
    } else {
      return _displayMobileBody(themeProvider);
    }
  }

  Widget _displayMobileBody(ThemeProvider themeProvider) {
    var body = _entries.isEmpty
        ? _displayMobileBodyEmpty(themeProvider)
        : _displayMobileBodyFull(themeProvider);

    if (Platform.isIOS) {
      return Column(
        children: [
          _displayIOsSearchBar(themeProvider),
          Expanded(child: body),
        ],
      );
    } else {
      return body;
    }
  }

  Widget _displayMobileBodyEmpty(ThemeProvider themeProvider) {
    return Container(
      margin: EdgeInsets.only(left: 32, right: 32, bottom: 50),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            "assets/images/empty_passwords.svg",
            semanticsLabel: 'Empty Password',
            fit: BoxFit.fitWidth,
            height: 200,
          ),
          ChicElevatedButton(
            child: Text(AppTranslations.of(context).text("new_password")),
            onPressed: _onAddEntryClicked,
          ),
        ],
      ),
    );
  }

  Widget _displayMobileBodyFull(ThemeProvider themeProvider) {
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

  Widget _displayDesktopBody(ThemeProvider themeProvider) {
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
              return FadeTransition(
                opacity: _animationOpacityController
                    .drive(CurveTween(curve: Curves.easeOut)),
                child: SlideTransition(
                  position: _offsetSlideAnimation,
                  child: EntryItem(
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
                  ),
                ),
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

  Widget _displayIOsSearchBar(ThemeProvider themeProvider) {
    return Container(
      padding: EdgeInsets.all(8),
      color: themeProvider.secondBackgroundColor,
      child: CupertinoSearchTextField(
        controller: _searchController,
        placeholder: AppTranslations.of(context).text("search_passwords"),
        onChanged: (String text) {
          _searchPassword(text);
        },
        onSuffixTap: () {
          _searchController.clear();
          FocusScope.of(context).requestFocus(FocusNode());
          _searchPassword("");
        },
      ),
    );
  }

  Widget _displaySearchBar(ThemeProvider themeProvider) {
    return ChicTextField(
      controller: _searchController,
      label: AppTranslations.of(context).text("search_passwords"),
      hint: AppTranslations.of(context).text("search_passwords"),
      desktopFocus: _desktopSearchFocusNode,
      focus: _searchFocusNode,
      type: ChicTextFieldType.filledRounded,
      floatingLabelBehavior: FloatingLabelBehavior.never,
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

  bool _isDesktopEntrySelected(int index) {
    if (_selectedEntries.isNotEmpty) {
      // Multi select
      return _selectedEntries.contains(_entries[index]);
    } else {
      // Single select
      return _selectedEntry != null && _selectedEntry!.id == _entries[index].id;
    }
  }

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
        await ChicNavigator.push(
          context,
          EntryDetailScreen(
            entry: entry,
            previousPageTitle: AppTranslations.of(context).text("passwords"),
          ),
        );
        await _loadPassword(isClearingSearch: false);
        await _searchPassword(_searchController.text);
      }

      setState(() {});
    }
  }

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
        NewEntryScreen(
          previousPageTitle: AppTranslations.of(context).text("passwords"),
        ),
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
    _animationOpacityController.dispose();
    _animationSlideController.dispose();

    super.dispose();
  }

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

  _onMovingToCategory(Entry entry) async {
    var isMultiSelected = _selectedEntries.isNotEmpty;

    var category = await ChicNavigator.push(
      context,
      SelectCategoryScreen(
        previousPageTitle: AppTranslations.of(context).text("passwords"),
      ),
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
