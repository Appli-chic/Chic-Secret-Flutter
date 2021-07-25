import 'package:chic_secret/localization/app_translations.dart';
import 'package:chic_secret/model/database/user.dart';
import 'package:chic_secret/provider/synchronization_provider.dart';
import 'package:chic_secret/provider/theme_provider.dart';
import 'package:chic_secret/service/user_service.dart';
import 'package:chic_secret/ui/component/common/chic_elevated_button.dart';
import 'package:chic_secret/ui/component/common/chic_navigator.dart';
import 'package:chic_secret/ui/component/common/desktop_modal.dart';
import 'package:chic_secret/ui/component/setting_item.dart';
import 'package:chic_secret/ui/screen/biometry_screen.dart';
import 'package:chic_secret/ui/screen/import_screen.dart';
import 'package:chic_secret/ui/screen/subscribe_screen.dart';
import 'package:chic_secret/ui/screen/vaults_screen.dart';
import 'package:chic_secret/utils/chic_platform.dart';
import 'package:chic_secret/utils/import_export.dart';
import 'package:chic_secret/utils/security.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'login_screen.dart';
import 'new_vault_screen.dart';

class SettingsScreen extends StatefulWidget {
  final Function()? onDataChanged;
  final bool hasVaultLinked;

  SettingsScreen({
    this.onDataChanged,
    this.hasVaultLinked = false,
  });

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  final LocalAuthentication auth = LocalAuthentication();
  late SynchronizationProvider _synchronizationProvider;
  User? _user;
  late AnimationController _synchronizingAnimationController;
  bool _isBiometricsSupported = false;

  @override
  void initState() {
    _synchronizingAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _checkBiometrics();
    _getUser();

    super.initState();
  }

  /// Checks if the biometrics are supported on this device
  _checkBiometrics() async {
    try {
      _isBiometricsSupported = await auth.canCheckBiometrics;
      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  /// Retrieve the user information
  _getUser() async {
    _user = await Security.getCurrentUser();
    if (_user != null) {
      _user = await UserService.getUserById(_user!.id);
    }
    setState(() {});
  }

  _startsAnimatingSynchronisation() {
    if (!_synchronizingAnimationController.isAnimating) {
      _synchronizingAnimationController.forward();
      _synchronizingAnimationController.repeat();
    }
  }

  _stopAnimatingSynchronisation() {
    _synchronizingAnimationController.stop();
  }

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context, listen: true);
    _synchronizationProvider =
        Provider.of<SynchronizationProvider>(context, listen: true);

    // Starts and stop the synchronization animation
    if (_synchronizationProvider.isSynchronizing) {
      _startsAnimatingSynchronisation();
    } else {
      _stopAnimatingSynchronisation();
    }

    if (ChicPlatform.isDesktop()) {
      return _displaysDesktopInModal(themeProvider);
    } else {
      return _displaysMobile(themeProvider);
    }
  }

  /// Displays the screen in a modal for the desktop version
  Widget _displaysDesktopInModal(ThemeProvider themeProvider) {
    return DesktopModal(
      title: AppTranslations.of(context).text("settings"),
      body: _displaysBody(themeProvider),
      actions: [
        Container(
          margin: EdgeInsets.only(right: 8, bottom: 8),
          child: ChicElevatedButton(
            child: Text(AppTranslations.of(context).text("ok")),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
      ],
    );
  }

  /// Displays the [Scaffold] for the mobile version
  Widget _displaysMobile(ThemeProvider themeProvider) {
    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(
        backgroundColor: themeProvider.secondBackgroundColor,
        brightness: themeProvider.getBrightness(),
        title: Text(AppTranslations.of(context).text("settings")),
        actions: [],
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: _displaysBody(themeProvider),
        ),
      ),
    );
  }

  /// Displays a unified body for both mobile and desktop version
  Widget _displaysBody(ThemeProvider themeProvider) {
    String? lastSyncDate;

    // Get last date synchronization
    if (_synchronizationProvider.lastSyncDate != null) {
      var locale = AppTranslations.of(context).locale;
      var time = DateFormat.Hm(locale.languageCode)
          .format(_synchronizationProvider.lastSyncDate!);

      var date = DateFormat.yMMMMEEEEd(locale.languageCode)
          .format(_synchronizationProvider.lastSyncDate!);

      lastSyncDate = "$time - $date";
    }

    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Column(
        children: [
          _user != null
              ? SettingItem(
                  leading: Icon(Icons.person),
                  title: Text(_user!.email),
                )
              : SettingItem(
                  leading: Icon(Icons.login),
                  title: Text(AppTranslations.of(context).text("login")),
                  onTap: _login,
                ),
          _user != null
              ? SettingItem(
                  leading: RotationTransition(
                    turns: Tween(begin: 1.0, end: 0.0)
                        .animate(_synchronizingAnimationController),
                    child: Icon(Icons.sync),
                  ),
                  title:
                      Text(AppTranslations.of(context).text("synchronizing")),
                  subtitle: _displaysSynchronizationSubtitle(lastSyncDate),
                  onTap: _synchronize,
                )
              : SizedBox.shrink(),
          // _user != null
          //     ? SettingItem(
          //         leading: Icon(Icons.subscriptions),
          //         title: Text(AppTranslations.of(context).text("subscription")),
          //         onTap: _onSubscribeClicked,
          //       )
          //     : SizedBox.shrink(),
          selectedVault != null
              ? SettingItem(
                  leading: Icon(Icons.import_export_outlined),
                  title: Text(
                      AppTranslations.of(context).text("import_buttercup")),
                  onTap: _importData,
                )
              : SizedBox.shrink(),
          !ChicPlatform.isDesktop() &&
                  _isBiometricsSupported &&
                  widget.hasVaultLinked
              ? SettingItem(
                  leading: Icon(Icons.fingerprint),
                  title: Text(AppTranslations.of(context).text("biometry")),
                  onTap: _onBiometryClicked,
                )
              : SizedBox.shrink(),
          widget.hasVaultLinked && selectedVault != null
              ? SettingItem(
                  leading: Icon(Icons.edit),
                  title: Text(AppTranslations.of(context).text("edit_vault")),
                  onTap: _onEditVaultClicked,
                )
              : SizedBox.shrink(),
          _user != null
              ? SettingItem(
                  backgroundColor: Colors.red[500],
                  leading: Icon(Icons.logout,
                      color: ChicPlatform.isDesktop() ? Colors.red[500] : null),
                  title: Text(
                    AppTranslations.of(context).text("logout"),
                    style: TextStyle(
                        color:
                            ChicPlatform.isDesktop() ? Colors.red[500] : null),
                  ),
                  onTap: _logout,
                )
              : SizedBox.shrink(),
        ],
      ),
    );
  }

  /// On subscribe clicked move to the subscribe page
  _onEditVaultClicked() async {
    var isDeleted = await ChicNavigator.push(
      context,
      NewVaultScreen(vault: selectedVault, isFromSettings: true),
      isModal: true,
    );

    if (widget.onDataChanged != null) {
      widget.onDataChanged!();
    }

    if (isDeleted != null && isDeleted) {
      if (!ChicPlatform.isDesktop()) {
        Navigator.pop(context, true);
      }
    }
  }

  /// Displays the last time it synchronized
  Widget? _displaysSynchronizationSubtitle(String? lastSyncDate) {
    if (lastSyncDate != null) {
      return Text(lastSyncDate);
    }

    return null;
  }

  /// On subscribe clicked move to the subscribe page
  _onSubscribeClicked() async {
    await ChicNavigator.push(
      context,
      SubscribeScreen(),
      isModal: true,
    );

    _getUser();
  }

  /// Synchronize the data with the server
  _synchronize() async {
    await _synchronizationProvider.synchronize(isFullSynchronization: true);

    if (widget.onDataChanged != null) {
      widget.onDataChanged!();
    }
  }

  /// Logout the user and delete the data about the user
  _logout() async {
    await Security.logout();
    Navigator.of(context).pop(true);
  }

  /// Send to the login page
  _login() async {
    var isLogged = await ChicNavigator.push(
      context,
      LoginScreen(),
      isModal: true,
    );

    if (isLogged) {
      _getUser();
      await _synchronizationProvider.synchronize(isFullSynchronization: true);

      if (widget.onDataChanged != null) {
        widget.onDataChanged!();
      }
    }
  }

  /// Import the data from another password manager
  _importData() async {
    var data = await importFromFile(ImportType.Buttercup);

    if (data != null) {
      await ChicNavigator.push(
        context,
        ImportScreen(importData: data),
        isModal: true,
      );

      if (widget.onDataChanged != null) {
        widget.onDataChanged!();
      }

      _synchronizationProvider.synchronize(isFullSynchronization: true);

      if (ChicPlatform.isDesktop()) {
        Navigator.pop(context, true);
      }
    }
  }

  /// Send to the biometry page to activate or deactivate the biometry
  _onBiometryClicked() async {
    await ChicNavigator.push(
      context,
      BiometryScreen(),
    );
  }
}
