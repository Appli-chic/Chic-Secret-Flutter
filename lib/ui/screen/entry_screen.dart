import 'package:chic_secret/localization/app_translations.dart';
import 'package:chic_secret/model/database/entry.dart';
import 'package:chic_secret/provider/theme_provider.dart';
import 'package:chic_secret/service/entry_service.dart';
import 'package:chic_secret/ui/component/common/chic_icon_button.dart';
import 'package:chic_secret/ui/component/common/chic_navigator.dart';
import 'package:chic_secret/ui/component/common/chic_text_field.dart';
import 'package:chic_secret/ui/component/entry_item.dart';
import 'package:chic_secret/ui/screen/entry_detail_screen.dart';
import 'package:chic_secret/ui/screen/new_entry_screen.dart';
import 'package:chic_secret/ui/screen/vaults_screen.dart';
import 'package:chic_secret/utils/chic_platform.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EntryScreenController {
  void Function()? reloadPasswords;

  EntryScreenController({
    this.reloadPasswords,
  });
}

class PasswordsScreen extends StatefulWidget {
  final EntryScreenController? passwordScreenController;
  final Function()? reloadCategories;
  final Function(Entry entry)? onEntrySelected;

  const PasswordsScreen({
    this.passwordScreenController,
    this.reloadCategories,
    this.onEntrySelected,
  });

  @override
  _PasswordsScreenState createState() => _PasswordsScreenState();
}

class _PasswordsScreenState extends State<PasswordsScreen> {
  List<Entry> _entries = [];
  Entry? _selectedEntry;

  final _searchController = TextEditingController();
  var _searchFocusNode = FocusNode();
  var _desktopSearchFocusNode = FocusNode();

  @override
  void initState() {
    if (widget.passwordScreenController != null) {
      widget.passwordScreenController!.reloadPasswords = _loadPassword;
    }

    _loadPassword();

    super.initState();
  }

  /// Load the list of passwords linked to the current vault
  _loadPassword() async {
    if (selectedVault != null) {
      if (selectedCategory.id.isEmpty) {
        // Load all the passwords in the current vault
        _entries = await EntryService.getAllByVault(selectedVault!.id);
      } else {
        // Load the passwords in the current vault and selected category
        _entries = await EntryService.getAllByVaultAndCategory(
            selectedVault!.id, selectedCategory.id);
      }

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
          Row(
            children: [
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 16, top: 16),
                  child: ChicTextField(
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
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 16, right: 16, top: 16),
                child: ChicIconButton(
                  onPressed: _onAddEntryClicked,
                  icon: Icons.add,
                  type: ChicIconButtonType.filledRectangle,
                ),
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _entries.length,
              itemBuilder: (context, index) {
                return EntryItem(
                  entry: _entries[index],
                  isSelected: _selectedEntry != null &&
                      _selectedEntry == _entries[index],
                  onTap: _onEntrySelected,
                );
              },
            ),
          ),
        ],
      );
    }

    return ListView.builder(
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
    var data = await ChicNavigator.push(
      context,
      NewEntryScreen(),
      isModal: true,
    );

    if (widget.reloadCategories != null) {
      widget.reloadCategories!();
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
