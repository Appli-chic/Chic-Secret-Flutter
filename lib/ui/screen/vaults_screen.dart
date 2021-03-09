import 'dart:io';

import 'package:chic_secret/localization/app_translations.dart';
import 'package:chic_secret/model/database/vault.dart';
import 'package:chic_secret/provider/theme_provider.dart';
import 'package:chic_secret/service/vault_service.dart';
import 'package:chic_secret/ui/component/common/chic_navigator.dart';
import 'package:chic_secret/ui/component/common/chic_text_icon_button.dart';
import 'package:chic_secret/ui/component/vault_item.dart';
import 'package:chic_secret/ui/screen/new_vault_screen.dart';
import 'package:chic_secret/ui/screen/unlock_vault_screen.dart';
import 'package:chic_secret/utils/chic_platform.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Vault? selectedVault;

class VaultsScreen extends StatefulWidget {
  final Function() onVaultChange;

  VaultsScreen({
    required this.onVaultChange,
  });

  @override
  _VaultsScreenState createState() => _VaultsScreenState();
}

class _VaultsScreenState extends State<VaultsScreen> {
  List<Vault> _vaults = [];

  @override
  void initState() {
    _loadVaults();
    super.initState();
  }

  _loadVaults() async {
    _vaults = await VaultService.getAll();
    setState(() {});
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
                _displayVaults(themeProvider),
                _displayCategories(themeProvider),
                _displayTags(themeProvider),
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

  Widget _displayVaults(ThemeProvider themeProvider) {
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
                if (await _isVaultUnlocking(vault)) {
                  selectedVault = vault;
                  setState(() {});
                }
              },
            );
          },
        ),
      ],
    );
  }

  Widget _displayCategories(ThemeProvider themeProvider) {
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
          itemCount: 0,
          itemBuilder: (context, index) {
            return Container();
          },
        ),
      ],
    );
  }

  Widget _displayTags(ThemeProvider themeProvider) {
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
          itemCount: 0,
          itemBuilder: (context, index) {
            return Container();
          },
        ),
      ],
    );
  }

  Widget _displaysMobileBody(ThemeProvider themeProvider) {
    return ListView.builder(
      itemCount: _vaults.length,
      itemBuilder: (context, index) {
        return VaultItem(
          isSelected: false,
          vault: _vaults[index],
          onTap: (vault) async {
            if (await _isVaultUnlocking(vault)) {}
          },
        );
      },
    );
  }

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

  _onAddVaultClicked() async {
    var data =
        await ChicNavigator.push(context, NewVaultScreen(), isModal: true);

    if (data != null) {
      _loadVaults();
    }
  }

  Future<bool> _isVaultUnlocking(Vault vault) async {
    var isUnlocked = await ChicNavigator.push(
      context,
      UnlockVaultScreen(vault: vault),
      isModal: true,
    );

    if (isUnlocked != null && isUnlocked) {
      return true;
    }

    return false;
  }
}
