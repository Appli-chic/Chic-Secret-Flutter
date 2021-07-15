import 'package:chic_secret/model/database/entry.dart';
import 'package:chic_secret/provider/theme_provider.dart';
import 'package:chic_secret/ui/component/common/split_view.dart';
import 'package:chic_secret/ui/screen/entry_detail_screen.dart';
import 'package:chic_secret/ui/screen/entry_screen.dart';
import 'package:chic_secret/ui/screen/new_entry_screen.dart';
import 'package:chic_secret/ui/screen/vaults_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainDesktopScreenController {
  void Function()? reloadAfterSynchronization;

  MainDesktopScreenController({
    this.reloadAfterSynchronization,
  });
}

class MainDesktopScreen extends StatefulWidget {
  final MainDesktopScreenController mainDesktopScreenController;

  MainDesktopScreen({
    required this.mainDesktopScreenController,
  });

  @override
  _MainDesktopScreenState createState() => _MainDesktopScreenState();
}

class _MainDesktopScreenState extends State<MainDesktopScreen> {
  Entry? _selectedEntry;
  bool _isCreatingOrModifyingEntry = false;
  VaultScreenController _vaultScreenController = VaultScreenController();
  EntryScreenController _entryScreenController = EntryScreenController();

  @override
  void initState() {
    widget.mainDesktopScreenController.reloadAfterSynchronization =
        _reloadAfterSynchronization;

    super.initState();
  }

  /// Reload after a synchronization
  _reloadAfterSynchronization() {
    if (_vaultScreenController.reloadVaults != null) {
      _vaultScreenController.reloadVaults!();
    }

    if (_vaultScreenController.reloadCategories != null) {
      _vaultScreenController.reloadCategories!();
    }

    if (_entryScreenController.reloadPasswords != null) {
      _entryScreenController.reloadPasswords!();
    }

    setState(() {});
  }

  /// Ask to reload the passwords from the [EntryScreen] when the vault change
  _reloadPasswordScreenOnVaultChange() {
    _selectedEntry = null;

    if (_entryScreenController.reloadPasswords != null) {
      _entryScreenController.reloadPasswords!();
    }

    setState(() {});
  }

  /// Ask to reload the passwords from the [EntryScreen] when the category change
  _reloadPasswordScreenOnCategoryChange() {
    if (_entryScreenController.reloadPasswords != null) {
      _entryScreenController.reloadPasswords!();
    }

    setState(() {});
  }

  /// Ask to reload the passwords from the [EntryScreen] when the tag change
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
    _isCreatingOrModifyingEntry = false;
    setState(() {});
  }

  /// Displays [NewEntryScreen] instead of the entry detail
  _onCreateNewEntry() {
    _selectedEntry = null;
    _isCreatingOrModifyingEntry = true;

    if (_entryScreenController.selectEntry != null) {
      _entryScreenController.selectEntry!(null);
    }

    setState(() {});
  }

  /// Cancels the display of creation of a new entry
  _onNewEntryFinished(Entry? entry) {
    _isCreatingOrModifyingEntry = false;
    _reloadTags();

    if (_vaultScreenController.reloadCategories != null) {
      _vaultScreenController.reloadCategories!();
    }

    if (entry != null) {
      if (_entryScreenController.reloadPasswords != null) {
        _entryScreenController.reloadPasswords!();
      }

      _onEntrySelected(entry);

      if (_entryScreenController.selectEntry != null) {
        _entryScreenController.selectEntry!(entry);
      }
    }

    setState(() {});
  }

  /// Triggered when then the user click on the edit button of a created entry
  _onEditEntry(Entry entry) {
    _isCreatingOrModifyingEntry = true;
    _selectedEntry = entry;

    if (_vaultScreenController.reloadCategories != null) {
      _vaultScreenController.reloadCategories!();
    }

    setState(() {});
  }

  /// Triggered when the user deleted a selected entry
  _onEntryDeleted() {
    _isCreatingOrModifyingEntry = false;
    _selectedEntry = null;

    if (_vaultScreenController.reloadCategories != null) {
      _vaultScreenController.reloadCategories!();
    }

    if (_entryScreenController.reloadPasswords != null) {
      _entryScreenController.reloadPasswords!();
    }

    if (_entryScreenController.selectEntry != null) {
      _entryScreenController.selectEntry!(null);
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context, listen: true);

    return Scaffold(
      body: SplitView(
        gripColor: themeProvider.divider,
        positionLimit: 200,
        view1: VaultsScreen(
          onVaultChange: _reloadPasswordScreenOnVaultChange,
          onCategoryChange: _reloadPasswordScreenOnCategoryChange,
          onTagChange: _reloadPasswordScreenOnTagChange,
          vaultScreenController: _vaultScreenController,
        ),
        view2: SplitView(
          gripColor: themeProvider.divider,
          positionLimit: 300,
          view1: EntryScreen(
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
    if (_isCreatingOrModifyingEntry) {
      return NewEntryScreen(
        entry: _selectedEntry,
        onFinish: _onNewEntryFinished,
        onReloadCategories: _reloadCategories,
      );
    } else if (_selectedEntry != null) {
      return EntryDetailScreen(
        entry: _selectedEntry!,
        onEntryEdit: _onEditEntry,
        onEntryDeleted: _onEntryDeleted,
      );
    } else {
      return Container(color: themeProvider.backgroundColor);
    }
  }
}
