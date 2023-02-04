import 'dart:io';

import 'package:chic_secret/features/vault/unlock/unlock_vault_screen_view_model.dart';
import 'package:chic_secret/localization/app_translations.dart';
import 'package:chic_secret/model/database/vault.dart';
import 'package:chic_secret/provider/theme_provider.dart';
import 'package:chic_secret/ui/component/common/chic_elevated_button.dart';
import 'package:chic_secret/ui/component/common/chic_text_button.dart';
import 'package:chic_secret/ui/component/common/chic_text_field.dart';
import 'package:chic_secret/ui/component/common/desktop_modal.dart';
import 'package:chic_secret/utils/chic_platform.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UnlockVaultScreen extends StatefulWidget {
  final Vault vault;
  final bool isUnlocking;

  UnlockVaultScreen({
    required this.vault,
    this.isUnlocking = false,
  });

  @override
  _UnlockVaultScreenState createState() => _UnlockVaultScreenState();
}

class _UnlockVaultScreenState extends State<UnlockVaultScreen> {
  late UnlockVaultScreenViewModel _viewModel;

  var _passwordFocusNode = FocusNode();
  var _desktopPasswordFocusNode = FocusNode();

  @override
  void initState() {
    _viewModel = UnlockVaultScreenViewModel(widget.vault, widget.isUnlocking);
    _viewModel.unlockWithBiometry(context);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context, listen: true);

    return ChangeNotifierProvider<UnlockVaultScreenViewModel>(
        create: (BuildContext context) => _viewModel,
        child: Consumer<UnlockVaultScreenViewModel>(
            builder: (context, value, _) {
              if (ChicPlatform.isDesktop()) {
                return _displaysDesktopInModal(themeProvider);
              } else {
                return _displaysMobile(themeProvider);
              }
            }
        )
    );
  }

  Widget _displaysDesktopInModal(ThemeProvider themeProvider) {
    return DesktopModal(
      title: AppTranslations.of(context).text("unlock_vault"),
      height: 110,
      body: _displaysBody(themeProvider),
      actions: [
        Container(
          margin: EdgeInsets.only(right: 8, bottom: 8),
          child: ChicTextButton(
            child: Text(AppTranslations.of(context).text("cancel")),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        Container(
          margin: EdgeInsets.only(right: 8, bottom: 8),
          child: ChicElevatedButton(
            child: Text(AppTranslations.of(context).text("unlock")),
            onPressed: () {
              _viewModel.unlockVault(context);
            },
          ),
        ),
      ],
    );
  }

  Widget _displaysMobile(ThemeProvider themeProvider) {
    if (Platform.isIOS) {
      return CupertinoPageScaffold(
        backgroundColor: themeProvider.backgroundColor,
        navigationBar: _displaysIosAppbar(themeProvider),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: _displaysBody(themeProvider),
        ),
      );
    } else {
      return Scaffold(
        backgroundColor: themeProvider.backgroundColor,
        appBar: _displaysAppbar(themeProvider),
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: _displaysBody(themeProvider),
        ),
      );
    }
  }

  ObstructingPreferredSizeWidget _displaysIosAppbar(
      ThemeProvider themeProvider,) {
    return CupertinoNavigationBar(
      previousPageTitle: AppTranslations.of(context).text("vaults"),
      backgroundColor: themeProvider.secondBackgroundColor,
      middle: Text(AppTranslations.of(context).text("unlock_vault")),
      trailing: CupertinoButton(
        padding: EdgeInsets.zero,
        child: Text(AppTranslations.of(context).text("unlock")),
        onPressed: () {
          _viewModel.unlockVault(context);
        },
      ),
    );
  }

  PreferredSizeWidget? _displaysAppbar(ThemeProvider themeProvider) {
    if (!ChicPlatform.isDesktop()) {
      return AppBar(
        backgroundColor: themeProvider.secondBackgroundColor,
        title: Text(AppTranslations.of(context).text("unlock_vault")),
        actions: [
          ChicTextButton(
            child: Text(AppTranslations.of(context).text("unlock")),
            onPressed: () {
              _viewModel.unlockVault(context);
            },
          ),
        ],
      );
    } else {
      return null;
    }
  }

  Widget _displaysBody(ThemeProvider themeProvider) {
    return Container(
      margin: EdgeInsets.all(16),
      child: Form(
        key: _viewModel.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ChicTextField(
              controller: _viewModel.passwordController,
              focus: _passwordFocusNode,
              desktopFocus: _desktopPasswordFocusNode,
              autoFocus: true,
              isPassword: true,
              textInputAction: TextInputAction.done,
              label: AppTranslations.of(context).text("password"),
              errorMessage:
              AppTranslations.of(context).text("error_empty_password"),
              validating: (String text) {
                return _viewModel.passwordController.text.isNotEmpty;
              },
              onSubmitted: (String text) {
                _viewModel.unlockVault(context);
              },
            ),
            _viewModel.isPasswordIncorrect &&
                _viewModel.passwordController.text.isNotEmpty
                ? Container(
              margin: EdgeInsets.only(top: 8, left: 8),
              child: Text(
                AppTranslations.of(context).text("password_incorrect"),
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                ),
              ),
            )
                : Container(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _viewModel.passwordController.dispose();
    _passwordFocusNode.dispose();
    _desktopPasswordFocusNode.dispose();

    super.dispose();
  }
}
