import 'dart:io';

import 'package:chic_secret/localization/app_translations.dart';
import 'package:chic_secret/model/database/category.dart';
import 'package:chic_secret/model/database/tag.dart';
import 'package:chic_secret/model/database/vault.dart';
import 'package:chic_secret/provider/theme_provider.dart';
import 'package:chic_secret/service/category_service.dart';
import 'package:chic_secret/service/tag_service.dart';
import 'package:chic_secret/service/vault_service.dart';
import 'package:chic_secret/ui/component/category_item.dart';
import 'package:chic_secret/ui/component/common/chic_icon_button.dart';
import 'package:chic_secret/ui/component/common/chic_navigator.dart';
import 'package:chic_secret/ui/component/common/chic_text_icon_button.dart';
import 'package:chic_secret/ui/component/tag_item.dart';
import 'package:chic_secret/ui/component/vault_item.dart';
import 'package:chic_secret/ui/screen/main_mobile_screen.dart';
import 'package:chic_secret/ui/screen/new_category_screen.dart';
import 'package:chic_secret/ui/screen/new_vault_screen.dart';
import 'package:chic_secret/ui/screen/unlock_vault_screen.dart';
import 'package:chic_secret/utils/chic_platform.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Vault? selectedVault;
String? currentPassword;

/// The map is composed of the vault ID as a key and the password as the value
Map<String, String> vaultPasswordMap = Map();

Category? selectedCategory;
Tag? selectedTag;

class VaultScreenController {
  void Function()? reloadCategories;
  void Function()? reloadTags;

  VaultScreenController({
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
  List<Vault> _vaults = [];
  List<Category> _categories = [];
  List<Tag> _tags = [];

  @override
  void initState() {
    if (widget.vaultScreenController != null) {
      widget.vaultScreenController!.reloadCategories = _loadCategories;
      widget.vaultScreenController!.reloadTags = _loadTags;
    }

    _loadVaults();
    super.initState();
  }

  /// Loads all the vaults from the database
  _loadVaults() async {
    _vaults = await VaultService.getAll();
    setState(() {});
  }

  /// Loads the categories linked to the current vault
  _loadCategories() async {
    if (selectedVault != null) {
      _categories = await CategoryService.getAllByVault(selectedVault!.id);
      setState(() {});
    }
  }

  /// Loads the tags linked to the current vault
  _loadTags() async {
    if (selectedVault != null) {
      _tags = await TagService.getAllByVault(selectedVault!.id);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context, listen: true);

    return Scaffold(
      backgroundColor: ChicPlatform.isDesktop()
          ? themeProvider.sidebarBackgroundColor
          : themeProvider.backgroundColor,
      appBar: _displaysAppbar(themeProvider),
      body: ChicPlatform.isDesktop()
          ? _displaysDesktopBody(themeProvider)
          : _displaysMobileBody(themeProvider),
      floatingActionButton: _displaysFloatingActionButton(themeProvider),
    );
  }

  /// Displays the body corresponding only to the desktop version
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
          Container(
            margin: EdgeInsets.only(left: 16, bottom: 8, top: 6),
            child: ChicTextIconButton(
              onPressed: _onAddVaultClicked,
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

  /// Displays the list of vaults for the desktop version
  Widget _displaysVaults(ThemeProvider themeProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.only(left: 8),
              child: Text(
                AppTranslations.of(context).text("vaults"),
                style: TextStyle(
                  color: themeProvider.labelColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ),
            ChicIconButton(
              icon: Icons.add,
              size: 17,
              color: themeProvider.textColor,
              onPressed: _onAddVaultClicked,
            ),
          ],
        ),
        ListView.builder(
          shrinkWrap: true,
          itemCount: _vaults.length,
          itemBuilder: (context, index) {
            bool isSelected =
                selectedVault != null && selectedVault!.id == _vaults[index].id;

            return VaultItem(
              isSelected: isSelected,
              vault: _vaults[index],
              onTap: (vault) async {
                var unlockingPassword;

                if (vaultPasswordMap[vault.id] != null) {
                  // The vault is already unlocked
                  unlockingPassword = vaultPasswordMap[vault.id];
                } else {
                  // The vault need to be unlocked
                  unlockingPassword = await _isVaultUnlocking(vault);

                  // If the vault haven't been unlocked then we stop it there
                  if (unlockingPassword == null) {
                    return;
                  }

                  // We just unlocked the vault so we save this information
                  vaultPasswordMap[vault.id] = unlockingPassword;
                }

                // Set the selected category back to null
                selectedCategory = null;
                selectedVault = vault;
                currentPassword = unlockingPassword;

                // Reload the data for this vault
                widget.onVaultChange();
                _loadCategories();
                _loadTags();

                setState(() {});
              },
            );
          },
        ),
      ],
    );
  }

  /// Displays the categories for the desktop version
  Widget _displaysCategories(ThemeProvider themeProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.only(left: 8),
              child: Text(
                AppTranslations.of(context).text("categories"),
                style: TextStyle(
                  color: themeProvider.labelColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ),
            ChicIconButton(
              icon: Icons.add,
              size: 17,
              color: themeProvider.textColor,
              onPressed: _onAddCategoryClicked,
            ),
          ],
        ),
        ListView.builder(
          shrinkWrap: true,
          itemCount: _categories.length + 1,
          itemBuilder: (context, index) {
            // Add a "Fake" category to display all the passwords
            if (index == 0) {
              return CategoryItem(
                isSelected: selectedCategory == null,
                onTap: (Category? category) {
                  selectedCategory = category;

                  if (widget.onCategoryChange != null) {
                    widget.onCategoryChange!();
                  }

                  setState(() {});
                },
              );
            } else {
              return CategoryItem(
                category: _categories[index - 1],
                isSelected: selectedCategory != null &&
                    selectedCategory!.id == _categories[index - 1].id,
                onTap: (Category? category) {
                  selectedCategory = category;

                  if (widget.onCategoryChange != null) {
                    widget.onCategoryChange!();
                  }

                  setState(() {});
                },
              );
            }
          },
        ),
      ],
    );
  }

  /// Displays the list of tags for the desktop version
  Widget _displaysTags(ThemeProvider themeProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(left: 8, bottom: 12, top: 8),
          child: Text(
            AppTranslations.of(context).text("tags"),
            style: TextStyle(
              color: themeProvider.labelColor,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          itemCount: _tags.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              // Displays a "no tag" to stop the filter on tags
              return TagItem(
                isSelected: selectedTag == null,
                onTap: (Tag? tag) {
                  selectedTag = null;

                  if (widget.onTagChange != null) {
                    widget.onTagChange!();
                  }

                  setState(() {});
                },
              );
            } else {
              // Display a tag
              return TagItem(
                tag: _tags[index - 1],
                isSelected: selectedTag != null &&
                    selectedTag!.id == _tags[index - 1].id,
                onTap: (Tag? tag) {
                  selectedTag = tag;

                  if (widget.onTagChange != null) {
                    widget.onTagChange!();
                  }

                  setState(() {});
                },
              );
            }
          },
        ),
      ],
    );
  }

  /// Displays the list of vaults only for the mobile version
  Widget _displaysMobileBody(ThemeProvider themeProvider) {
    return ListView.builder(
      itemCount: _vaults.length,
      itemBuilder: (context, index) {
        return VaultItem(
          isSelected: false,
          vault: _vaults[index],
          onTap: (vault) async {
            var unlockingPassword = await _isVaultUnlocking(vault);

            if (unlockingPassword != null) {
              selectedVault = vault;
              currentPassword = unlockingPassword;
              await ChicNavigator.push(context, MainMobileScreen());
            }
          },
        );
      },
    );
  }

  /// Displays a floating action button only for the mobile version
  /// to create new vaults.
  Widget? _displaysFloatingActionButton(ThemeProvider themeProvider) {
    if (Platform.isAndroid) {
      return FloatingActionButton(
        onPressed: _onAddVaultClicked,
        backgroundColor: themeProvider.primaryColor,
        child: Icon(Icons.add, color: themeProvider.textColor),
      );
    } else {
      return null;
    }
  }

  /// Displays the appbar only for the mobile version
  PreferredSizeWidget? _displaysAppbar(ThemeProvider themeProvider) {
    if (!ChicPlatform.isDesktop()) {
      return AppBar(
        backgroundColor: themeProvider.secondBackgroundColor,
        brightness: themeProvider.getBrightness(),
        title: Text(AppTranslations.of(context).text("vaults")),
        actions: [
          IconButton(
            icon: Icon(
              Icons.add,
              color: themeProvider.textColor,
            ),
            onPressed: _onAddVaultClicked,
          )
        ],
      );
    } else {
      return null;
    }
  }

  /// Calls the [NewVaultScreen] screen to create a new vault
  _onAddVaultClicked() async {
    var data = await ChicNavigator.push(
      context,
      NewVaultScreen(),
      isModal: true,
    );

    if (data != null) {
      _loadVaults();

      // Select the vault and start working on it
      widget.onVaultChange();

      // Only load categories and tags if it's the desktop version
      if (ChicPlatform.isDesktop()) {
        _loadCategories();
        _loadTags();
      }

      if (!ChicPlatform.isDesktop()) {
        await ChicNavigator.push(context, MainMobileScreen());
      }
    }
  }

  /// Calls the [NewCategoryScreen] screen to create a new category
  _onAddCategoryClicked() async {
    var data = await ChicNavigator.push(
      context,
      NewCategoryScreen(),
      isModal: true,
    );

    if (data != null) {
      _loadCategories();
    }
  }

  /// Check if the vault is unlocked and returns the password used
  /// to unlock the vault
  Future<String?> _isVaultUnlocking(Vault vault) async {
    var unlockingPassword = await ChicNavigator.push(
      context,
      UnlockVaultScreen(vault: vault),
      isModal: true,
    );

    return unlockingPassword;
  }
}
