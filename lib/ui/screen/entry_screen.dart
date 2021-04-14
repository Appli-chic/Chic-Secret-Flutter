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

  final _searchController = TextEditingController();
  var _searchFocusNode = FocusNode();
  var _desktopSearchFocusNode = FocusNode();

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

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: _displaysAppbar(themeProvider),
      body: _displayBody(themeProvider),
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
                  isSelected: _selectedEntry != null &&
                      _selectedEntry!.id == _entries[index].id,
                  onTap: _onEntrySelected,
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

  /// When the entry is selected by the user, it will display the user screen
  _onEntrySelected(Entry entry) async {
    _selectedEntry = entry;

    if (ChicPlatform.isDesktop()) {
      if (widget.onEntrySelected != null) {
        widget.onEntrySelected!(entry);
      }
    } else {
      await ChicNavigator.push(context, EntryDetailScreen(entry: entry));
    }

    setState(() {});
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
      _entries = await EntryService.getAllByVault(selectedVault!.id);
      setState(() {});
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _desktopSearchFocusNode.dispose();

    super.dispose();
  }
}
