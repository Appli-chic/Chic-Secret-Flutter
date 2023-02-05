import 'dart:io';
import 'dart:math';

import 'package:chic_secret/component/common/chic_elevated_button.dart';
import 'package:chic_secret/component/common/chic_navigator.dart';
import 'package:chic_secret/component/common/chic_text_button.dart';
import 'package:chic_secret/component/common/chic_text_field.dart';
import 'package:chic_secret/component/common/chic_text_icon_button.dart';
import 'package:chic_secret/component/entry_item.dart';
import 'package:chic_secret/feature/category/select_category/select_category_screen.dart';
import 'package:chic_secret/feature/entry/entries_screen_view_model.dart';
import 'package:chic_secret/localization/app_translations.dart';
import 'package:chic_secret/model/database/category.dart';
import 'package:chic_secret/model/database/entry.dart';
import 'package:chic_secret/provider/synchronization_provider.dart';
import 'package:chic_secret/provider/theme_provider.dart';
import 'package:chic_secret/ui/screen/new_entry_screen.dart';
import 'package:chic_secret/utils/chic_platform.dart';
import 'package:chic_secret/utils/shared_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class EntriesScreenController {
  void Function({bool isClearingSearch})? reloadPasswords;
  void Function(Entry?)? selectEntry;

  EntriesScreenController({
    this.reloadPasswords,
    this.selectEntry,
  });
}

class EntriesScreen extends StatefulWidget {
  final EntriesScreenController? passwordScreenController;
  final Function()? reloadCategories;
  final Function()? reloadTags;
  final Function(Entry entry)? onEntrySelected;
  final Function()? onCreateNewEntry;

  const EntriesScreen({
    this.passwordScreenController,
    this.reloadCategories,
    this.reloadTags,
    this.onEntrySelected,
    this.onCreateNewEntry,
  });

  @override
  _EntriesScreenState createState() => _EntriesScreenState();
}

class _EntriesScreenState extends State<EntriesScreen>
    with
        AutomaticKeepAliveClientMixin<EntriesScreen>,
        TickerProviderStateMixin {
  late EntriesScreenViewModel _viewModel;
  late SynchronizationProvider _synchronizationProvider;

  FocusNode _searchFocusNode = FocusNode();
  FocusNode _desktopSearchFocusNode = FocusNode();
  FocusNode _shortcutsFocusNode = FocusNode();

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
    _viewModel = EntriesScreenViewModel(widget.onEntrySelected);

    if (!Platform.isMacOS) {
      _manageScroll();
    }

    if (widget.passwordScreenController != null) {
      widget.passwordScreenController!.reloadPasswords = _loadPassword;
      widget.passwordScreenController!.selectEntry = _viewModel.selectEntry;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var themeProvider = Provider.of<ThemeProvider>(context, listen: true);
    _synchronizationProvider =
        Provider.of<SynchronizationProvider>(context, listen: true);

    return ChangeNotifierProvider<EntriesScreenViewModel>(
      create: (BuildContext context) => _viewModel,
      child: Consumer<EntriesScreenViewModel>(
        builder: (context, value, _) {
          return RawKeyboardListener(
            autofocus: true,
            focusNode: _shortcutsFocusNode,
            onKey: (RawKeyEvent event) {
              _viewModel.onKeyChanged(event, _searchFocusNode.hasFocus);
            },
            child: _displayScaffold(themeProvider),
          );
        },
      ),
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
                          _viewModel.searchController.clear();
                          FocusScope.of(context).requestFocus(FocusNode());
                          _viewModel.searchPassword("");
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
    var body = _viewModel.entries.isEmpty
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
        itemCount: _viewModel.entries.length,
        itemBuilder: (context, index) {
          return EntryItem(
            entry: _viewModel.entries[index],
            isSelected: false,
            isWeakPassword: _viewModel.weakPasswordEntries
                .where((e) => e.id == _viewModel.entries[index].id)
                .isNotEmpty,
            isOldPassword: _viewModel.oldEntries
                .where((e) => e.id == _viewModel.entries[index].id)
                .isNotEmpty,
            isDuplicatedPassword: _viewModel.duplicatedEntries
                .where((e) => e.id == _viewModel.entries[index].id)
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
            itemCount: _viewModel.entries.length,
            itemBuilder: (context, index) {
              return FadeTransition(
                opacity: _animationOpacityController
                    .drive(CurveTween(curve: Curves.easeOut)),
                child: SlideTransition(
                  position: _offsetSlideAnimation,
                  child: EntryItem(
                    entry: _viewModel.entries[index],
                    isSelected: _viewModel.isDesktopEntrySelected(index),
                    onTap: _onEntrySelected,
                    onMovingEntryToTrash: _onMovingEntryToTrash,
                    onMovingToCategory: _onMovingToCategory,
                    isControlKeyDown: _viewModel.isControlKeyDown,
                    isWeakPassword: _viewModel.weakPasswordEntries
                        .where((e) => e.id == _viewModel.entries[index].id)
                        .isNotEmpty,
                    isOldPassword: _viewModel.oldEntries
                        .where((e) => e.id == _viewModel.entries[index].id)
                        .isNotEmpty,
                    isDuplicatedPassword: _viewModel.duplicatedEntries
                        .where((e) => e.id == _viewModel.entries[index].id)
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
        controller: _viewModel.searchController,
        placeholder: AppTranslations.of(context).text("search_passwords"),
        onChanged: (String text) {
          _viewModel.searchPassword(text);
        },
        onSuffixTap: () {
          _viewModel.searchController.clear();
          FocusScope.of(context).requestFocus(FocusNode());
          _viewModel.searchPassword("");
        },
      ),
    );
  }

  Widget _displaySearchBar(ThemeProvider themeProvider) {
    return ChicTextField(
      controller: _viewModel.searchController,
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
        _viewModel.searchPassword(text);
      },
    );
  }

  _loadPassword({bool isClearingSearch = true}) async {
    await _viewModel.loadPassword(isClearingSearch: isClearingSearch);

    _animationOpacityController.reset();
    _animationOpacityController.forward();
    _animationSlideController.reset();
    _animationSlideController.forward();
  }

  _onEntrySelected(Entry entry) {
    _viewModel.onEntrySelected(entry, context);
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

  _onMovingEntryToTrash(Entry entry) async {
    var isAlreadyInTrash = entry.category!.isTrash;
    var isMultiSelected = _viewModel.selectedEntries.isNotEmpty;
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
      _viewModel.onMovingEntriesToTrash(
        _synchronizationProvider,
        entry,
        isAlreadyInTrash,
        isMultiSelected,
      );
    }
  }

  _onMovingToCategory(Entry entry) async {
    var category = await ChicNavigator.push(
      context,
      SelectCategoryScreen(
        previousPageTitle: AppTranslations.of(context).text("passwords"),
      ),
      isModal: true,
    );

    if (category != null && category is Category) {
      _viewModel.onMovingToCategory(_synchronizationProvider, entry, category);
    }
  }

  _manageScroll() {
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

    _animationOpacityController.forward();
    _animationSlideController.forward();
  }

  @override
  void dispose() {
    _viewModel.searchController.dispose();
    _searchFocusNode.dispose();
    _desktopSearchFocusNode.dispose();
    _shortcutsFocusNode.dispose();
    _animationOpacityController.dispose();
    _animationSlideController.dispose();

    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;
}
