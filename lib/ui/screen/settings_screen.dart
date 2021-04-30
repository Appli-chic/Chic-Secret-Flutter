import 'package:chic_secret/localization/app_translations.dart';
import 'package:chic_secret/model/database/user.dart';
import 'package:chic_secret/provider/synchronization_provider.dart';
import 'package:chic_secret/provider/theme_provider.dart';
import 'package:chic_secret/ui/component/common/chic_elevated_button.dart';
import 'package:chic_secret/ui/component/common/chic_navigator.dart';
import 'package:chic_secret/ui/component/common/desktop_modal.dart';
import 'package:chic_secret/ui/screen/import_screen.dart';
import 'package:chic_secret/utils/chic_platform.dart';
import 'package:chic_secret/utils/import_export.dart';
import 'package:chic_secret/utils/security.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late SynchronizationProvider _synchronizationProvider;
  User? _user;

  @override
  void initState() {
    _getUser();
    super.initState();
  }

  /// Retrieve the user information
  _getUser() async {
    _user = await Security.getCurrentUser();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context, listen: true);
    _synchronizationProvider =
        Provider.of<SynchronizationProvider>(context, listen: true);

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

    if (_synchronizationProvider.lastSyncDate != null) {
      var locale = AppTranslations.of(context).locale;
      lastSyncDate = DateFormat.yMMMd(locale.languageCode)
          .format(_synchronizationProvider.lastSyncDate!);
    }

    return Column(
      children: [
        _user != null
            ? ListTile(
                leading: Icon(Icons.person),
                title: Text(_user!.email),
              )
            : ListTile(
                leading: Icon(Icons.login),
                title: Text(AppTranslations.of(context).text("login")),
                onTap: _login,
              ),
        _user != null
            ? ListTile(
                leading: Icon(Icons.sync),
                title: Text(AppTranslations.of(context).text("synchronizing")),
                subtitle: lastSyncDate != null ? Text(lastSyncDate) : null,
                onTap: () {},
              )
            : SizedBox.shrink(),
        ListTile(
          leading: Icon(Icons.import_export_outlined),
          title: Text(AppTranslations.of(context).text("import_buttercup")),
          onTap: _importData,
        ),
      ],
    );
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
    }
  }

  /// Import the data from another password manager
  _importData() async {
    var data = await importFromFile(ImportType.Buttercup);

    await ChicNavigator.push(
      context,
      ImportScreen(importData: data),
      isModal: true,
    );

    if (ChicPlatform.isDesktop()) {
      Navigator.pop(context, true);
    }
  }
}
