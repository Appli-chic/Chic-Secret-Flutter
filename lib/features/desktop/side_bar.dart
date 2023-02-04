import 'package:chic_secret/features/desktop/side_bar_view_model.dart';
import 'package:chic_secret/localization/app_translations.dart';
import 'package:chic_secret/model/database/category.dart';
import 'package:chic_secret/model/database/tag.dart';
import 'package:chic_secret/model/database/vault.dart';
import 'package:chic_secret/provider/synchronization_provider.dart';
import 'package:chic_secret/provider/theme_provider.dart';
import 'package:chic_secret/ui/component/category_item.dart';
import 'package:chic_secret/ui/component/common/chic_navigator.dart';
import 'package:chic_secret/ui/component/common/chic_text_icon_button.dart';
import 'package:chic_secret/ui/component/desktop_expandable_menu.dart';
import 'package:chic_secret/ui/component/tag_item.dart';
import 'package:chic_secret/ui/component/vault_item.dart';
import 'package:chic_secret/ui/screen/login_screen.dart';
import 'package:chic_secret/ui/screen/new_category_screen.dart';
import 'package:chic_secret/ui/screen/new_vault_screen.dart';
import 'package:chic_secret/features/settings/settings_screen.dart';
import 'package:chic_secret/features/vault/unlock/unlock_vault_screen.dart';
import 'package:chic_secret/utils/shared_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';

class SideBarController {
  void Function()? reloadVaults;
  void Function()? reloadCategories;
  void Function()? reloadTags;

  SideBarController({
    this.reloadVaults,
    this.reloadCategories,
    this.reloadTags,
  });
}

class SideBar extends StatefulWidget {
  final Function() onVaultChange;
  final Function()? onCategoryChange;
  final Function()? onTagChange;
  final SideBarController? sideBarController;

  SideBar({
    required this.onVaultChange,
    this.onCategoryChange,
    this.onTagChange,
    this.sideBarController,
  });

  @override
  State<SideBar> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  late SideBarViewModel _viewModel;
  late SynchronizationProvider _synchronizationProvider;

  @override
  void initState() {
    _viewModel = SideBarViewModel(widget.onVaultChange);

    if (widget.sideBarController != null) {
      widget.sideBarController!.reloadVaults = _viewModel.onSynchronized;
      widget.sideBarController!.reloadCategories =
          _viewModel.loadCategories;
      widget.sideBarController!.reloadTags = _viewModel.loadTags;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context, listen: true);
    _synchronizationProvider =
        Provider.of<SynchronizationProvider>(context, listen: true);

    return ChangeNotifierProvider<SideBarViewModel>(
      create: (BuildContext context) => _viewModel,
      child: Consumer<SideBarViewModel>(
        builder: (context, value, _) {
          return Scaffold(
            backgroundColor: themeProvider.sidebarBackgroundColor,
            body: _displaysDesktopBody(themeProvider),
          );
        },
      ),
    );
  }

  Widget _displaysDesktopBody(ThemeProvider themeProvider) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Scrollbar(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _displaysVaults(themeProvider),
                    selectedVault != null
                        ? _displaysCategories(themeProvider)
                        : SizedBox.shrink(),
                    selectedVault != null
                        ? _displaysTags(themeProvider)
                        : SizedBox.shrink(),
                  ],
                ),
              ),
            ),
          ),
          !_viewModel.isUserLoggedIn && selectedVault == null
              ? Container(
            margin: EdgeInsets.only(left: 16, bottom: 8, top: 6),
            child: ChicTextIconButton(
              onPressed: _onLogin,
              icon: Icon(
                Icons.login,
                color: themeProvider.textColor,
                size: 18,
              ),
              label: Text(
                AppTranslations.of(context).text("login"),
                style: TextStyle(
                  color: themeProvider.textColor,
                  fontSize: 13,
                ),
              ),
            ),
          )
              : Container(
            margin: EdgeInsets.only(left: 16, bottom: 8, top: 6),
            child: ChicTextIconButton(
              onPressed: _onOptionsClicked,
              icon: Icon(
                Icons.settings,
                color: themeProvider.textColor,
                size: 18,
              ),
              label: Text(
                AppTranslations.of(context).text("settings"),
                style: TextStyle(
                  color: themeProvider.textColor,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _displaysVaults(ThemeProvider themeProvider) {
    return Container(
      margin: EdgeInsets.only(top: 8),
      child: DesktopExpandableMenu(
        title: AppTranslations.of(context).text("vaults"),
        onAddButtonClicked: _onAddVaultClicked,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: _viewModel.vaults.length,
          itemBuilder: (context, index) {
            bool isSelected = selectedVault != null &&
                selectedVault!.id == _viewModel.vaults[index].id;

            return VaultItem(
              isSelected: isSelected,
              vault: _viewModel.vaults[index],
              onVaultChanged: () {
                widget.onVaultChange();
              },
              onTap: (Vault vault) {
                _viewModel.onAddVault(vault, _goToUnlockVault);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _displaysCategories(ThemeProvider themeProvider) {
    return DesktopExpandableMenu(
      title: AppTranslations.of(context).text("categories"),
      onAddButtonClicked: _onAddCategoryClicked,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: _viewModel.categories.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            // Add a "Fake" category to display all the passwords
            return CategoryItem(
              isSelected: selectedCategory == null,
              nbWeakPasswords: _viewModel.weakPasswordEntries.length,
              nbOldPasswords: _viewModel.oldEntries.length,
              nbDuplicatedPasswords: _viewModel.duplicatedEntries.length,
              onTap: _onDesktopCategoryClicked,
            );
          } else {
            return CategoryItem(
              category: _viewModel.categories[index - 1],
              isSelected: selectedCategory != null &&
                  selectedCategory!.id == _viewModel.categories[index - 1].id,
              nbWeakPasswords: !_viewModel.categories[index - 1].isTrash
                  ? _viewModel.weakPasswordEntries
                  .where((e) =>
              e.category?.id == _viewModel.categories[index - 1].id)
                  .toList()
                  .length
                  : 0,
              nbOldPasswords: !_viewModel.categories[index - 1].isTrash
                  ? _viewModel.oldEntries
                  .where((e) =>
              e.category?.id == _viewModel.categories[index - 1].id)
                  .toList()
                  .length
                  : 0,
              nbDuplicatedPasswords: !_viewModel.categories[index - 1].isTrash
                  ? _viewModel.duplicatedEntries
                  .where((e) =>
              e.category?.id == _viewModel.categories[index - 1].id)
                  .toList()
                  .length
                  : 0,
              onTap: _onDesktopCategoryClicked,
              onCategoryChanged: _onCategoryChanged,
            );
          }
        },
      ),
    );
  }

  Widget _displaysTags(ThemeProvider themeProvider) {
    return DesktopExpandableMenu(
      title: AppTranslations.of(context).text("tags"),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: _viewModel.tags.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            // Displays a "no tag" to stop the filter on tags
            return TagItem(
              isSelected: selectedTag == null,
              onTap: _onNoTagClicked,
            );
          } else {
            // Display a tag
            return TagItem(
              tag: _viewModel.tags[index - 1],
              isSelected: selectedTag != null &&
                  selectedTag!.id == _viewModel.tags[index - 1].id,
              onTap: _onTagClicked,
              onTagChanged: _onTagChanged,
            );
          }
        },
      ),
    );
  }

  _onAddVaultClicked() async {
    var data = await ChicNavigator.push(
      context,
      NewVaultScreen(),
      isModal: true,
    );

    if (data != null) {
      _viewModel.loadVaults();

      // Select the vault and start working on it
      widget.onVaultChange();

      _viewModel.loadCategories();
      _viewModel.loadTags();
    }
  }

  _onAddCategoryClicked() async {
    var data = await ChicNavigator.push(
      context,
      NewCategoryScreen(
        previousPageTitle: AppTranslations.of(context).text("vaults"),
      ),
      isModal: true,
    );

    if (data != null) {
      _viewModel.loadCategories();
    }
  }

  _onDesktopCategoryClicked(Category? category) {
    if (selectedCategory != category) {
      selectedCategory = category;

      if (widget.onCategoryChange != null) {
        widget.onCategoryChange!();
      }
    }
  }

  _onCategoryChanged() {
    _viewModel.loadCategories();

    if (widget.onCategoryChange != null) {
      widget.onCategoryChange!();
    }
  }

  _onNoTagClicked(Tag? tag) {
    selectedTag = null;

    if (widget.onTagChange != null) {
      widget.onTagChange!();
    }
  }

  _onTagClicked(Tag? tag) {
    selectedTag = tag;

    if (widget.onTagChange != null) {
      widget.onTagChange!();
    }
  }

  _onTagChanged(Tag tag, bool isDeleted) async {
    if (tag == selectedTag && isDeleted) {
      selectedTag = null;
    }

    await _viewModel.loadTags();
    widget.onVaultChange();
    if (widget.onTagChange != null) {
      widget.onTagChange!();
    }
  }

  _onOptionsClicked() async {
    var haveToReload = await ChicNavigator.push(
      context,
      SettingsScreen(
        hasVaultLinked: true,
        onDataChanged: _viewModel.onSynchronized,
      ),
      isModal: true,
    );

    if (haveToReload != null && haveToReload) {
      _viewModel.onSynchronized();
    }
  }

  _onLogin() async {
    var isLogged = await ChicNavigator.push(
      context,
      LoginScreen(),
      isModal: true,
    );

    if (isLogged != null && isLogged) {
      EasyLoading.show();

      await _synchronizationProvider.synchronize(isFullSynchronization: true);

      EasyLoading.dismiss();

      _viewModel.setUserLoggedIn();
      _viewModel.loadVaults();
    }
  }

  Future<String?> _goToUnlockVault(Vault vault) async {
    var unlockingPassword = await ChicNavigator.push(
      context,
      UnlockVaultScreen(vault: vault, isUnlocking: true),
      isModal: true,
    );

    return unlockingPassword;
  }
}
