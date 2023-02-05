import 'dart:io';

import 'package:chic_secret/component/common/chic_elevated_button.dart';
import 'package:chic_secret/component/common/chic_text_button.dart';
import 'package:chic_secret/component/common/chic_text_field.dart';
import 'package:chic_secret/component/common/desktop_modal.dart';
import 'package:chic_secret/features/user/login/login_screen_view_model.dart';
import 'package:chic_secret/localization/app_translations.dart';
import 'package:chic_secret/provider/theme_provider.dart';
import 'package:chic_secret/utils/chic_platform.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  LoginScreenViewModel _viewModel = LoginScreenViewModel();

  var _emailFocusNode = FocusNode();
  var _codeFocusNode = FocusNode();

  var _desktopEmailFocusNode = FocusNode();
  var _desktopCodeFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context, listen: true);

    return ChangeNotifierProvider<LoginScreenViewModel>(
      create: (BuildContext context) => _viewModel,
      child: Consumer<LoginScreenViewModel>(
        builder: (context, value, _) {
          if (ChicPlatform.isDesktop()) {
            return _displaysDesktopInModal(themeProvider);
          } else {
            return _displaysMobile(themeProvider);
          }
        },
      ),
    );
  }

  Widget _displaysDesktopInModal(ThemeProvider themeProvider) {
    return DesktopModal(
      title: AppTranslations.of(context).text("login"),
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
            child: Text(AppTranslations.of(context)
                .text(_viewModel.isAskingCode ? "next" : "done")),
            onPressed: _viewModel.isAskingCode ? _onAskingLoginCode : _onLogin,
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
        child: _displaysBody(themeProvider),
      );
    } else {
      return Scaffold(
        backgroundColor: themeProvider.backgroundColor,
        appBar: _displaysAppbar(themeProvider),
        body: _displaysBody(themeProvider),
      );
    }
  }

  ObstructingPreferredSizeWidget _displaysIosAppbar(
      ThemeProvider themeProvider) {
    return CupertinoNavigationBar(
      previousPageTitle: AppTranslations.of(context).text("settings"),
      backgroundColor: themeProvider.secondBackgroundColor,
      middle: Text(AppTranslations.of(context).text("login")),
      trailing: CupertinoButton(
        padding: EdgeInsets.zero,
        child: Text(
          AppTranslations.of(context)
              .text(_viewModel.isAskingCode ? "next" : "done"),
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        onPressed: _viewModel.isAskingCode ? _onAskingLoginCode : _onLogin,
      ),
    );
  }

  PreferredSizeWidget? _displaysAppbar(ThemeProvider themeProvider) {
    if (!ChicPlatform.isDesktop()) {
      return AppBar(
        backgroundColor: themeProvider.secondBackgroundColor,
        title: Text(AppTranslations.of(context).text("login")),
        actions: [
          ChicTextButton(
            child: Text(AppTranslations.of(context)
                .text(_viewModel.isAskingCode ? "next" : "done")),
            onPressed: _viewModel.isAskingCode ? _onAskingLoginCode : _onLogin,
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
              controller: _viewModel.emailController,
              focus: _emailFocusNode,
              desktopFocus: _desktopEmailFocusNode,
              autoFocus: true,
              textCapitalization: TextCapitalization.none,
              keyboardType: TextInputType.emailAddress,
              label: AppTranslations.of(context).text("email"),
              errorMessage: AppTranslations.of(context).text("error_email"),
              validating: (String text) {
                return _viewModel.checkEmailIsValid();
              },
              onSubmitted: (String text) {
                _codeFocusNode.requestFocus();
              },
            ),
            _isNotAskingCodeForm(themeProvider),
          ],
        ),
      ),
    );
  }

  Widget _isNotAskingCodeForm(ThemeProvider themeProvider) {
    if(_viewModel.isAskingCode) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
          SizedBox(height: 16.0),
          ChicTextField(
            controller: _viewModel.codeController,
            focus: _codeFocusNode,
            desktopFocus: _desktopCodeFocusNode,
            autoFocus: false,
            textCapitalization: TextCapitalization.none,
            keyboardType: TextInputType.number,
            label: AppTranslations.of(context).text("code"),
            errorMessage:
            AppTranslations.of(context).text("error_code"),
            validating: (String text) => text.isNotEmpty,
            onSubmitted: (String text) {
              if (_viewModel.isAskingCode) {
                _onAskingLoginCode();
              } else {
                _onLogin();
              }
            },
          ),
          SizedBox(height: 16.0),
          Text(
            AppTranslations.of(context).text("login_code_message"),
            style: TextStyle(
              color: themeProvider.secondTextColor,
              fontSize: 13,
              fontWeight: FontWeight.w300,
            ),
          ),
          SizedBox(height: 8.0),
          ChicTextButton(
            child: Text(
              AppTranslations.of(context).text("resend_code"),
              style: TextStyle(color: themeProvider.primaryColor),
            ),
            onPressed: _onAskingLoginCode,
          ),
        ],
    );
  }

  _onAskingLoginCode() {
    _viewModel.onAskingLoginCode(context);
  }

  _onLogin() {
    _viewModel.onLogin(context);
  }

  @override
  void dispose() {
    _viewModel.emailController.dispose();
    _viewModel.codeController.dispose();

    _emailFocusNode.dispose();
    _codeFocusNode.dispose();

    _desktopEmailFocusNode.dispose();
    _desktopCodeFocusNode.dispose();

    super.dispose();
  }
}
