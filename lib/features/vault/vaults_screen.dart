import 'dart:io';

import 'package:chic_secret/localization/app_translations.dart';
import 'package:chic_secret/model/database/vault.dart';
import 'package:chic_secret/provider/synchronization_provider.dart';
import 'package:chic_secret/provider/theme_provider.dart';
import 'package:chic_secret/ui/component/common/chic_elevated_button.dart';
import 'package:chic_secret/ui/component/common/chic_navigator.dart';
import 'package:chic_secret/ui/component/vault_item.dart';
import 'package:chic_secret/ui/screen/login_screen.dart';
import 'package:chic_secret/ui/screen/main_mobile_screen.dart';
import 'package:chic_secret/ui/screen/new_vault_screen.dart';
import 'package:chic_secret/ui/screen/settings_screen.dart';
import 'package:chic_secret/features/vault/unlock/unlock_vault_screen.dart';
import 'package:chic_secret/utils/shared_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import 'vaults_screen_view_model.dart';

class VaultScreenController {
  void Function()? reloadVaults;

  VaultScreenController({
    this.reloadVaults,
  });
}

class VaultsScreen extends StatefulWidget {
  final Function()? onCategoryChange;
  final Function()? onTagChange;
  final VaultScreenController? vaultScreenController;

  VaultsScreen({
    this.onCategoryChange,
    this.onTagChange,
    this.vaultScreenController,
  });

  @override
  _VaultsScreenState createState() => _VaultsScreenState();
}

class _VaultsScreenState extends State<VaultsScreen> {
  VaultsScreenViewModel _viewModel = VaultsScreenViewModel();
  late SynchronizationProvider _synchronizationProvider;

  @override
  void initState() {
    if (widget.vaultScreenController != null) {
      widget.vaultScreenController!.reloadVaults = _viewModel.loadVaults;
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
              backgroundColor: themeProvider.backgroundColor,
              appBar: _displaysAppbar(themeProvider),
              body: _displaysMobileBody(themeProvider),
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
    return AppBar(
      backgroundColor: themeProvider.secondBackgroundColor,
      title: Text(AppTranslations.of(context).text("vaults")),
      leading: _displaysAppBarLeadingIcon(themeProvider),
      actions: [_displaysActionIcon(themeProvider)],
    );
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

      await ChicNavigator.push(context, MainMobileScreen());
      _viewModel.checkIsUserLoggedIn();
      _viewModel.loadVaults();
    }
  }

  _onVaultClicked(vault) async {
    var unlockingPassword = await _goToUnlockVault(vault);

    if (unlockingPassword != null) {
      selectedVault = vault;
      currentPassword = unlockingPassword;

      await ChicNavigator.push(context, MainMobileScreen());

      _viewModel.loadVaults();
      _viewModel.checkIsUserLoggedIn();
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
