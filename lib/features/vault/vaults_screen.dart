import 'dart:io';

import 'package:chic_secret/localization/app_translations.dart';
import 'package:chic_secret/model/database/category.dart';
import 'package:chic_secret/model/database/tag.dart';
import 'package:chic_secret/model/database/vault.dart';
import 'package:chic_secret/provider/synchronization_provider.dart';
import 'package:chic_secret/provider/theme_provider.dart';
import 'package:chic_secret/service/entry_service.dart';
import 'package:chic_secret/ui/component/category_item.dart';
import 'package:chic_secret/ui/component/common/chic_elevated_button.dart';
import 'package:chic_secret/ui/component/common/chic_navigator.dart';
import 'package:chic_secret/ui/component/common/chic_text_icon_button.dart';
import 'package:chic_secret/ui/component/desktop_expandable_menu.dart';
import 'package:chic_secret/ui/component/tag_item.dart';
import 'package:chic_secret/ui/component/vault_item.dart';
import 'package:chic_secret/ui/screen/login_screen.dart';
import 'package:chic_secret/ui/screen/main_mobile_screen.dart';
import 'package:chic_secret/ui/screen/new_category_screen.dart';
import 'package:chic_secret/ui/screen/new_vault_screen.dart';
import 'package:chic_secret/ui/screen/settings_screen.dart';
import 'package:chic_secret/ui/screen/unlock_vault_screen.dart';
import 'package:chic_secret/utils/chic_platform.dart';
import 'package:chic_secret/utils/security.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import 'vaults_screen_view_model.dart';

Vault? selectedVault;
String? currentPassword;
Map<String, String> vaultPasswordMap = Map();
Category? selectedCategory;
Tag? selectedTag;

class VaultScreenController {
  void Function()? reloadVaults;
  void Function()? reloadCategories;
  void Function()? reloadTags;

  VaultScreenController({
    this.reloadVaults,
    this.reloadCategories,
    this.reloadTags,
  });
}

class VaultsScreen extends StatefulWidget {
  final Function() onVaultChange;
  final Function()? onCategoryChange;
  final Function()? onTagChange;
  final VaultScreenController? vaultScreenController;

  VaultsScreen({
    required this.onVaultChange,
    this.onCategoryChange,
    this.onTagChange,
    this.vaultScreenController,
  });

  @override
  _VaultsScreenState createState() => _VaultsScreenState();
}

class _VaultsScreenState extends State<VaultsScreen> {
  late VaultsScreenViewModel _viewModel;
  late SynchronizationProvider _synchronizationProvider;

  @override
  void initState() {
    _viewModel = VaultsScreenViewModel(widget.onVaultChange);

    if (widget.vaultScreenController != null) {
      widget.vaultScreenController!.reloadVaults = _viewModel.onSynchronized;
      widget.vaultScreenController!.reloadCategories =
          _viewModel.loadCategories;
      widget.vaultScreenController!.reloadTags = _viewModel.loadTags;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context, listen: true);
    _synchronizationProvider =
        Provider.of<SynchronizationProvider>(context, listen: true);

    return ChangeNotifierProvider<VaultsScreenViewModel>(
      create: (BuildContext context) => _viewModel,
      child: Consumer<VaultsScreenViewModel>(
        builder: (context, value, _) {
          if (Platform.isIOS) {
            return CupertinoPageScaffold(
              backgroundColor: themeProvider.backgroundColor,
              navigationBar: _iOSAppbar(themeProvider),
              child: _displaysMobileBody(themeProvider),
            );
          } else {
            return Scaffold(
              backgroundColor: ChicPlatform.isDesktop()
                  ? themeProvider.sidebarBackgroundColor
                  : themeProvider.backgroundColor,
              appBar: _displaysAppbar(themeProvider),
              body: ChicPlatform.isDesktop()
                  ? _displaysDesktopBody(themeProvider)
                  : _displaysMobileBody(themeProvider),
            );
          }
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
                _viewModel.onAddVaultDesktop(vault, _goToUnlockVault);
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

  Widget _displaysMobileBody(ThemeProvider themeProvider) {
    if (_viewModel.vaults.isEmpty) {
      return _displayMobileBodyEmpty(themeProvider);
    } else {
      return _displayMobileBodyFull(themeProvider);
    }
  }

  Widget _displayMobileBodyEmpty(ThemeProvider themeProvider) {
    return Container(
      margin: EdgeInsets.only(left: 32, right: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            "assets/images/empty_vault.svg",
            semanticsLabel: 'Empty Vault',
            fit: BoxFit.fitWidth,
            height: 200,
          ),
          ChicElevatedButton(
            child: Text(AppTranslations.of(context).text("new_vault")),
            onPressed: _onAddVaultClicked,
          ),
        ],
      ),
    );
  }

  Widget _displayMobileBodyFull(ThemeProvider themeProvider) {
    return ListView.builder(
      physics: BouncingScrollPhysics(),
      itemCount: _viewModel.vaults.length,
      itemBuilder: (context, index) {
        return VaultItem(
          isSelected: false,
          vault: _viewModel.vaults[index],
          onTap: _onVaultClicked,
        );
      },
    );
  }

  ObstructingPreferredSizeWidget _iOSAppbar(ThemeProvider themeProvider) {
    return CupertinoNavigationBar(
      automaticallyImplyLeading: false,
      backgroundColor: themeProvider.secondBackgroundColor,
      middle: Text(AppTranslations.of(context).text("vaults")),
      leading: _displaysAppBarLeadingIcon(themeProvider),
      trailing: _displaysActionIcon(themeProvider),
    );
  }

  PreferredSizeWidget? _displaysAppbar(ThemeProvider themeProvider) {
    if (!ChicPlatform.isDesktop()) {
      return AppBar(
        backgroundColor: themeProvider.secondBackgroundColor,
        title: Text(AppTranslations.of(context).text("vaults")),
        leading: _displaysAppBarLeadingIcon(themeProvider),
        actions: [_displaysActionIcon(themeProvider)],
      );
    } else {
      return null;
    }
  }

  Widget _displaysActionIcon(ThemeProvider themeProvider) {
    if (Platform.isIOS) {
      return CupertinoButton(
        padding: EdgeInsets.zero,
        alignment: Alignment.centerRight,
        child: Icon(
          CupertinoIcons.add,
        ),
        onPressed: _onAddVaultClicked,
      );
    } else {
      return IconButton(
        icon: Icon(
          Icons.add,
          color: themeProvider.textColor,
        ),
        onPressed: _onAddVaultClicked,
      );
    }
  }

  Widget _displaysAppBarLeadingIcon(ThemeProvider themeProvider) {
    if (Platform.isIOS) {
      if (!_viewModel.isUserLoggedIn) {
        return CupertinoButton(
          padding: EdgeInsets.zero,
          alignment: Alignment.centerLeft,
          child: Icon(
            CupertinoIcons.person_fill,
            color: themeProvider.textColor,
          ),
          onPressed: _onLogin,
        );
      } else {
        return CupertinoButton(
          padding: EdgeInsets.zero,
          alignment: Alignment.centerLeft,
          child: Icon(
            CupertinoIcons.settings,
            color: themeProvider.textColor,
          ),
          onPressed: _onStartSettings,
        );
      }
    } else {
      if (!_viewModel.isUserLoggedIn) {
        return IconButton(
          icon: Icon(
            Icons.person,
            color: themeProvider.textColor,
          ),
          onPressed: _onLogin,
        );
      } else {
        return IconButton(
          icon: Icon(
            Icons.settings,
            color: themeProvider.textColor,
          ),
          onPressed: _onStartSettings,
        );
      }
    }
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

      // Only load categories and tags if it's the desktop version
      if (ChicPlatform.isDesktop()) {
        _viewModel.loadCategories();
        _viewModel.loadTags();
      }

      if (!ChicPlatform.isDesktop()) {
        await ChicNavigator.push(context, MainMobileScreen());
        _viewModel.checkIsUserLoggedIn();
        _viewModel.loadVaults();
      }
    }
  }

  _onVaultClicked(vault) async {
    var unlockingPassword = await _goToUnlockVault(vault);

    if (unlockingPassword != null) {
      selectedVault = vault;
      currentPassword = unlockingPassword;

      // Set the entry length if they don't have one
      var entriesWithoutPasswordLength =
      await EntryService.getEntriesWithoutPasswordLength();

      Future(() async {
        for (var entry in entriesWithoutPasswordLength) {
          try {
            var password =
            Security.decrypt(currentPassword!, entry.hash);

            entry.passwordSize = password.length;
            entry.updatedAt = DateTime.now();
            await EntryService.update(entry);
          } catch (e) {
            print(e);
          }
        }

        _viewModel.checkPasswordSecurity();
      });

      // Move to the main screen
      await ChicNavigator.push(context, MainMobileScreen());

      _viewModel.loadVaults();
      _viewModel.checkIsUserLoggedIn();
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

    setState(() {});
  }

  _onTagClicked(Tag? tag) {
    selectedTag = tag;

    if (widget.onTagChange != null) {
      widget.onTagChange!();
    }

    setState(() {});
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

    setState(() {});
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

  _onStartSettings() async {
    await ChicNavigator.push(
      context,
      SettingsScreen(hasVaultLinked: false),
    );

    EasyLoading.show();

    await _synchronizationProvider.synchronize(isFullSynchronization: true);
    _viewModel.loadVaults();

    EasyLoading.dismiss();
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
