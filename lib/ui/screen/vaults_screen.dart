import 'dart:io';

import 'package:chic_secret/localization/app_translations.dart';
import 'package:chic_secret/provider/theme_provider.dart';
import 'package:chic_secret/ui/component/common/chic_text_icon_button.dart';
import 'file:///C:/Users/Lazyos/Desktop/Programmation/flutter/chic_secret/lib/ui/component/common/chic_navigator.dart';
import 'package:chic_secret/ui/component/vault_item.dart';
import 'package:chic_secret/ui/screen/new_vault_screen.dart';
import 'package:chic_secret/utils/chic_platform.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VaultsScreen extends StatefulWidget {
  @override
  _VaultsScreenState createState() => _VaultsScreenState();
}

class _VaultsScreenState extends State<VaultsScreen> {
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
            child: ListView(
              children: [
                VaultItem(isSelected: true),
                VaultItem(isSelected: false),
                VaultItem(isSelected: false),
                VaultItem(isSelected: false),
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

  Widget _displaysMobileBody(ThemeProvider themeProvider) {
    return Container();
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
    await ChicNavigator.push(context, NewVaultScreen(), isModal: true);
  }
}
