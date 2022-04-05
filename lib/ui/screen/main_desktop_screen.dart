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

  _reloadPasswordScreenOnVaultChange() {
    _selectedEntry = null;

    if (_entryScreenController.reloadPasswords != null) {
      _entryScreenController.reloadPasswords!();
    }

    setState(() {});
  }

  _reloadPasswordScreenOnCategoryChange() {
    if (_entryScreenController.reloadPasswords != null) {
      _entryScreenController.reloadPasswords!();
    }

    setState(() {});
  }

  _reloadPasswordScreenOnTagChange() {
    if (_entryScreenController.reloadPasswords != null) {
      _entryScreenController.reloadPasswords!();
    }

    setState(() {});
  }

  _reloadCategories() {
    if (_vaultScreenController.reloadCategories != null) {
      _vaultScreenController.reloadCategories!();
    }
  }

  _reloadTags() {
    if (_vaultScreenController.reloadTags != null) {
      _vaultScreenController.reloadTags!();
    }
  }

  _onEntrySelected(Entry entry) {
    _selectedEntry = entry;
    _isCreatingOrModifyingEntry = false;
    setState(() {});
  }

  _onCreateNewEntry() {
    _selectedEntry = null;
    _isCreatingOrModifyingEntry = true;

    if (_entryScreenController.selectEntry != null) {
      _entryScreenController.selectEntry!(null);
    }

    setState(() {});
  }

  _onNewEntryFinished(Entry? entry) {
    _isCreatingOrModifyingEntry = false;
    _reloadTags();

    if (_vaultScreenController.reloadCategories != null) {
      _vaultScreenController.reloadCategories!();
    }

    if (entry != null) {
      if (_entryScreenController.reloadPasswords != null) {
        _entryScreenController.reloadPasswords!(isClearingSearch: false);
      }

      _onEntrySelected(entry);

      if (_entryScreenController.selectEntry != null) {
        _entryScreenController.selectEntry!(entry);
      }
    }

    setState(() {});
  }

  _onEditEntry(Entry entry) {
    _isCreatingOrModifyingEntry = true;
    _selectedEntry = entry;

    if (_vaultScreenController.reloadCategories != null) {
      _vaultScreenController.reloadCategories!();
    }

    setState(() {});
  }

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
        onEntrySelected: _onEntrySelected,
      );
    } else {
      return Container(color: themeProvider.backgroundColor);
    }
  }
}
