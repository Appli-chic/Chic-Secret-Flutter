import 'dart:io';

import 'package:chic_secret/component/common/chic_navigator.dart';
import 'package:chic_secret/localization/app_translations.dart';
import 'package:chic_secret/provider/theme_provider.dart';
import 'package:chic_secret/feature/vault/unlock/unlock_vault_screen.dart';
import 'package:chic_secret/utils/security.dart';
import 'package:chic_secret/utils/shared_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BiometryScreen extends StatefulWidget {
  const BiometryScreen();

  @override
  _BiometryScreenState createState() => _BiometryScreenState();
}

class _BiometryScreenState extends State<BiometryScreen> {
  var _isBiometryActivated = false;

  @override
  void initState() {
    _getIfBiometryActivated();
    super.initState();
  }

  _getIfBiometryActivated() async {
    _isBiometryActivated =
        await Security.isPasswordSavedForBiometry(selectedVault!);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context, listen: true);

    if (Platform.isIOS) {
      return CupertinoPageScaffold(
        backgroundColor: themeProvider.backgroundColor,
        navigationBar: _displaysIosAppbar(themeProvider),
        child: _displayBody(themeProvider),
      );
    } else {
      return Scaffold(
        backgroundColor: themeProvider.backgroundColor,
        appBar: _displaysAppbar(themeProvider),
        body: _displayBody(themeProvider),
      );
    }
  }

  ObstructingPreferredSizeWidget _displaysIosAppbar(
      ThemeProvider themeProvider) {
    return CupertinoNavigationBar(
      previousPageTitle: AppTranslations.of(context).text("settings"),
      backgroundColor: themeProvider.secondBackgroundColor,
      middle: Text(AppTranslations.of(context).text("biometry")),
    );
  }

  PreferredSizeWidget? _displaysAppbar(ThemeProvider themeProvider) {
    return AppBar(
      backgroundColor: themeProvider.secondBackgroundColor,
      title: Text(AppTranslations.of(context).text("biometry")),
    );
  }

  Widget _displayBody(ThemeProvider themeProvider) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Container(
          margin: EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      AppTranslations.of(context).text("activated_biometry"),
                      style: TextStyle(
                        color: themeProvider.textColor,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  Switch.adaptive(
                    activeColor: themeProvider.primaryColor,
                    value: _isBiometryActivated,
                    onChanged: (bool value) async {
                      if (value) {
                        // We activate the biometry
                        var unlockingPassword = await ChicNavigator.push(
                          context,
                          UnlockVaultScreen(vault: selectedVault!),
                          isModal: true,
                        );

                        if (unlockingPassword != null) {
                          await Security.addPasswordForBiometry(
                              selectedVault!, unlockingPassword);
                          _isBiometryActivated = true;
                        }
                      } else {
                        // We deactivate the biometry
                        await Security.removePasswordFromBiometry(
                            selectedVault!);
                        _isBiometryActivated = false;
                      }

                      setState(() {});
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
