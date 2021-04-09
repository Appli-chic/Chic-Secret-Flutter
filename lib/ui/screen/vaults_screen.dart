import 'dart:io';

import 'package:chic_secret/localization/app_translations.dart';
import 'package:chic_secret/model/database/category.dart';
import 'package:chic_secret/model/database/entry.dart';
import 'package:chic_secret/model/database/tag.dart';
import 'package:chic_secret/model/database/vault.dart';
import 'package:chic_secret/provider/theme_provider.dart';
import 'package:chic_secret/service/category_service.dart';
import 'package:chic_secret/service/tag_service.dart';
import 'package:chic_secret/service/vault_service.dart';
import 'package:chic_secret/ui/component/category_item.dart';
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

Category selectedCategory = Category(
  id: "",
  name: "",
  color: "",
  icon: Icons.apps.codePoint,
  vaultId: "",
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);

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
  final VaultScreenController? vaultScreenController;

  VaultsScreen({
    required this.onVaultChange,
    this.onCategoryChange,
    this.vaultScreenController,
  });

  @override
  _VaultsScreenState createState() => _VaultsScreenState();
}

class _VaultsScreenState extends State<VaultsScreen> {
  Tag? _selectedTag;

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
      backgroundColor: themeProvider.backgroundColor,
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
      margin: EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
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
          Container(
            margin: EdgeInsets.only(left: 16, bottom: 8),
            child: ChicTextIconButton(
              onPressed: _onAddVaultClicked,
              icon: Icon(
                Icons.add,
                color: themeProvider.textColor,
                size: 20,
              ),
              label: Text(
                AppTranslations.of(context).text("new_vault"),
                style: TextStyle(color: themeProvider.textColor),
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
        Container(
          margin: EdgeInsets.only(left: 8, bottom: 8),
          child: Text(
            AppTranslations.of(context).text("vaults"),
            style: TextStyle(
              color: themeProvider.secondTextColor,
              fontWeight: FontWeight.w500,
            ),
          ),
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
                var unlockingPassword = await _isVaultUnlocking(vault);

                if (unlockingPassword != null) {
                  // Set the selected category back to "null"
                  selectedCategory = Category(
                    id: "",
                    name: "",
                    color: "",
                    icon: Icons.apps.codePoint,
                    vaultId: "",
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  );

                  selectedVault = vault;
                  currentPassword = unlockingPassword;
                  widget.onVaultChange();

                  // Only load categories and tags if it's the desktop version
                  if (ChicPlatform.isDesktop()) {
                    // Reload the categories from the selected vault
                    _loadCategories();
                    _loadTags();
                  }

                  setState(() {});
                }
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
        Container(
          margin: EdgeInsets.only(left: 8, bottom: 8, top: 16),
          child: Text(
            AppTranslations.of(context).text("categories"),
            style: TextStyle(
              color: themeProvider.secondTextColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          itemCount: _categories.length + 1,
          itemBuilder: (context, index) {
            var category;

            // Add a "Fake" category to display all the passwords
            if (index == 0) {
              category = Category(
                id: "",
                name: AppTranslations.of(context).text("all"),
                color: "#${themeProvider.primaryColor.value.toRadixString(16)}",
                icon: Icons.apps.codePoint,
                vaultId: "",
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              );
            } else {
              category = _categories[index - 1];
            }

            return CategoryItem(
              category: category,
              isSelected: selectedCategory.id == category.id,
              onTap: (Category category) {
                selectedCategory = category;

                if (widget.onCategoryChange != null) {
                  widget.onCategoryChange!();
                }

                setState(() {});
              },
            );
          },
        ),
        Container(
          margin: EdgeInsets.only(left: 16, bottom: 8, top: 8),
          child: ChicTextIconButton(
            onPressed: _onAddCategoryClicked,
            icon: Icon(
              Icons.add,
              color: themeProvider.textColor,
              size: 20,
            ),
            label: Text(
              AppTranslations.of(context).text("new_category"),
              style: TextStyle(color: themeProvider.textColor),
            ),
          ),
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
          margin: EdgeInsets.only(left: 8, bottom: 8, top: 16),
          child: Text(
            AppTranslations.of(context).text("tags"),
            style: TextStyle(
              color: themeProvider.secondTextColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          itemCount: _tags.length,
          itemBuilder: (context, index) {
            return TagItem(
              tag: _tags[index],
              isSelected:
                  _selectedTag != null && _selectedTag!.id == _tags[index].id,
              onTap: (Tag tag) {
                setState(() {
                  _selectedTag = tag;
                });
              },
            );
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
