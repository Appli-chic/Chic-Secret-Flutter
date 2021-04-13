import 'package:chic_secret/model/database/entry.dart';
import 'package:chic_secret/provider/theme_provider.dart';
import 'package:chic_secret/ui/component/common/split_view.dart';
import 'package:chic_secret/ui/screen/entry_detail_screen.dart';
import 'package:chic_secret/ui/screen/entry_screen.dart';
import 'package:chic_secret/ui/screen/new_entry_screen.dart';
import 'package:chic_secret/ui/screen/vaults_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainDesktopScreen extends StatefulWidget {
  @override
  _MainDesktopScreenState createState() => _MainDesktopScreenState();
}

class _MainDesktopScreenState extends State<MainDesktopScreen> {
  Entry? _selectedEntry;
  bool _isCreatingNewEntry = true;
  VaultScreenController _vaultScreenController = VaultScreenController();
  EntryScreenController _entryScreenController = EntryScreenController();

  /// Ask to reload the passwords from the [PasswordsScreen] when the vault change
  _reloadPasswordScreenOnVaultChange() {
    _selectedEntry = null;

    if (_entryScreenController.reloadPasswords != null) {
      _entryScreenController.reloadPasswords!();
    }

    setState(() {});
  }

  /// Ask to reload the passwords from the [PasswordsScreen] when the category change
  _reloadPasswordScreenOnCategoryChange() {
    if (_entryScreenController.reloadPasswords != null) {
      _entryScreenController.reloadPasswords!();
    }

    setState(() {});
  }

  /// Ask to reload the passwords from the [PasswordsScreen] when the tag change
  _reloadPasswordScreenOnTagChange() {
    if (_entryScreenController.reloadPasswords != null) {
      _entryScreenController.reloadPasswords!();
    }

    setState(() {});
  }

  /// Ask to reload the categories from the [VaultsScreen]
  _reloadCategories() {
    if (_vaultScreenController.reloadCategories != null) {
      _vaultScreenController.reloadCategories!();
    }
  }

  /// Ask to reload the tags from the [VaultsScreen]
  _reloadTags() {
    if (_vaultScreenController.reloadTags != null) {
      _vaultScreenController.reloadTags!();
    }
  }

  /// Reload the [EntryDetailScreen] with the new selected entry
  _onEntrySelected(Entry entry) {
    _selectedEntry = entry;
    _isCreatingNewEntry = false;
    setState(() {});
  }

  /// Displays [NewEntryScreen] instead of the entry detail
  _onCreateNewEntry() {
    _selectedEntry = null;
    _isCreatingNewEntry = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context, listen: true);

    return Scaffold(
      body: SplitView(
        gripColor: themeProvider.divider,
        view1: VaultsScreen(
          onVaultChange: _reloadPasswordScreenOnVaultChange,
          onCategoryChange: _reloadPasswordScreenOnCategoryChange,
          onTagChange: _reloadPasswordScreenOnTagChange,
          vaultScreenController: _vaultScreenController,
        ),
        view2: SplitView(
          gripColor: themeProvider.divider,
          view1: PasswordsScreen(
            passwordScreenController: _entryScreenController,
            reloadCategories: _reloadCategories,
            reloadTags: _reloadTags,
            onEntrySelected: _onEntrySelected,
            onCreateNewEntry: _onCreateNewEntry,
          ),
          view2: _displaysThirdSplitScreen(themeProvider),
          initialWeight: 0.4,
          onWeightChanged: (double value) {},
        ),
        onWeightChanged: (double value) {},
      ),
    );
  }

  /// Displays the third split screen with blank/[EntryDetailScreen]/[NewEntryScreen]
  Widget _displaysThirdSplitScreen(ThemeProvider themeProvider) {
    if (_isCreatingNewEntry) {
      return NewEntryScreen();
    } else if (_selectedEntry != null) {
      return EntryDetailScreen(entry: _selectedEntry!);
    } else {
      return Container(color: themeProvider.backgroundColor);
    }
  }
}
