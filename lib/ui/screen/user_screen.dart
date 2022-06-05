import 'dart:io';

import 'package:chic_secret/api/user_api.dart';
import 'package:chic_secret/localization/app_translations.dart';
import 'package:chic_secret/model/database/user.dart';
import 'package:chic_secret/provider/theme_provider.dart';
import 'package:chic_secret/service/user_service.dart';
import 'package:chic_secret/ui/component/common/chic_elevated_button.dart';
import 'package:chic_secret/ui/component/common/desktop_modal.dart';
import 'package:chic_secret/ui/component/setting_item.dart';
import 'package:chic_secret/utils/chic_platform.dart';
import 'package:chic_secret/utils/security.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({Key? key}) : super(key: key);

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  User? _user;

  @override
  void initState() {
    _getUser();
    super.initState();
  }

  _getUser() async {
    _user = await Security.getCurrentUser();
    if (_user != null) {
      _user = await UserService.getUserById(_user!.id);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context, listen: true);

    if (ChicPlatform.isDesktop()) {
      return _displaysDesktopInModal(themeProvider);
    } else {
      return _displaysMobile(themeProvider);
    }
  }

  Widget _displaysDesktopInModal(ThemeProvider themeProvider) {
    return DesktopModal(
      title: AppTranslations.of(context).text("user"),
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

  Widget _displaysMobile(ThemeProvider themeProvider) {
    var body = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: _displaysBody(themeProvider),
      ),
    );

    if (Platform.isIOS) {
      return CupertinoPageScaffold(
        backgroundColor: themeProvider.backgroundColor,
        navigationBar: _displaysIosAppbar(themeProvider),
        child: body,
      );
    } else {
      return Scaffold(
        backgroundColor: themeProvider.backgroundColor,
        appBar: _displaysAppbar(themeProvider),
        body: body,
      );
    }
  }

  ObstructingPreferredSizeWidget _displaysIosAppbar(
      ThemeProvider themeProvider) {
    return CupertinoNavigationBar(
      previousPageTitle: AppTranslations.of(context).text("settings"),
      backgroundColor: themeProvider.secondBackgroundColor,
      middle: Text(AppTranslations.of(context).text("user")),
    );
  }

  PreferredSizeWidget? _displaysAppbar(ThemeProvider themeProvider) {
    return AppBar(
      backgroundColor: themeProvider.secondBackgroundColor,
      title: Text(AppTranslations.of(context).text("user")),
    );
  }

  Widget _displaysBody(ThemeProvider themeProvider) {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Column(
        children: [
          _user != null
              ? SettingItem(
                  backgroundColor: Colors.red[500],
                  tint: ChicPlatform.isDesktop() ? Colors.red[500] : null,
                  leading: Platform.isIOS
                      ? CupertinoIcons.square_arrow_left
                      : Icons.logout,
                  title: AppTranslations.of(context).text("logout"),
                  onTap: _logout,
                )
              : SizedBox.shrink(),
          _user != null
              ? SettingItem(
                  backgroundColor: Colors.red[500],
                  tint: ChicPlatform.isDesktop() ? Colors.red[500] : null,
                  leading: Platform.isIOS
                      ? CupertinoIcons.delete
                      : Icons.delete_forever,
                  title: AppTranslations.of(context).text("delete_account"),
                  onTap: _deleteAccount,
                )
              : SizedBox.shrink(),
        ],
      ),
    );
  }

  _logout() async {
    await Security.logout();
    Navigator.of(context).pop(true);
  }

  _deleteAccount() async {
    try {
      EasyLoading.show();
      await UserApi.deleteUser();
    } catch (e) {}

    EasyLoading.dismiss();

    _logout();
  }
}
