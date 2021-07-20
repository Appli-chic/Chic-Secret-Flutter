import 'package:chic_secret/api/auth_api.dart';
import 'package:chic_secret/api/user_api.dart';
import 'package:chic_secret/localization/app_translations.dart';
import 'package:chic_secret/model/api_error.dart';
import 'package:chic_secret/provider/theme_provider.dart';
import 'package:chic_secret/service/user_service.dart';
import 'package:chic_secret/ui/component/common/chic_elevated_button.dart';
import 'package:chic_secret/ui/component/common/chic_text_button.dart';
import 'package:chic_secret/ui/component/common/chic_text_field.dart';
import 'package:chic_secret/ui/component/common/desktop_modal.dart';
import 'package:chic_secret/utils/chic_platform.dart';
import 'package:chic_secret/utils/constant.dart';
import 'package:chic_secret/utils/security.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _codeController = TextEditingController();

  var _emailFocusNode = FocusNode();
  var _codeFocusNode = FocusNode();

  var _desktopEmailFocusNode = FocusNode();
  var _desktopCodeFocusNode = FocusNode();

  bool _isAskingCode = true;

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context, listen: true);

    if (ChicPlatform.isDesktop()) {
      return _displaysDesktopInModal(themeProvider);
    } else {
      return _displaysMobile(themeProvider);
    }
  }

  /// Displays the screen in a modal for the desktop version
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
                .text(_isAskingCode ? "next" : "done")),
            onPressed: _isAskingCode ? _onAskingLoginCode : _onLogin,
          ),
        ),
      ],
    );
  }

  /// Displays the [Scaffold] for the mobile version
  Widget _displaysMobile(ThemeProvider themeProvider) {
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

  /// Displays the appBar for the mobile version
  PreferredSizeWidget? _displaysAppbar(ThemeProvider themeProvider) {
    if (!ChicPlatform.isDesktop()) {
      return AppBar(
        backgroundColor: themeProvider.secondBackgroundColor,
        brightness: themeProvider.getBrightness(),
        title: Text(AppTranslations.of(context).text("login")),
        actions: [
          ChicTextButton(
            child: Text(AppTranslations.of(context)
                .text(_isAskingCode ? "next" : "done")
                .toUpperCase()),
            onPressed: _isAskingCode ? _onAskingLoginCode : _onLogin,
          ),
        ],
      );
    } else {
      return null;
    }
  }

  /// Displays a unified body for both mobile and desktop version
  Widget _displaysBody(ThemeProvider themeProvider) {
    return Container(
      margin: EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ChicTextField(
              controller: _emailController,
              focus: _emailFocusNode,
              desktopFocus: _desktopEmailFocusNode,
              autoFocus: true,
              textCapitalization: TextCapitalization.none,
              keyboardType: TextInputType.emailAddress,
              hint: AppTranslations.of(context).text("email"),
              errorMessage: AppTranslations.of(context).text("error_email"),
              validating: (String text) {
                return RegExp(
                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-z"
                        r"A-Z0-9]+\.[a-zA-Z]+")
                    .hasMatch(_emailController.text);
              },
            ),
            !_isAskingCode ? SizedBox(height: 16.0) : SizedBox.shrink(),
            !_isAskingCode
                ? ChicTextField(
                    controller: _codeController,
                    focus: _codeFocusNode,
                    desktopFocus: _desktopCodeFocusNode,
                    autoFocus: true,
                    textCapitalization: TextCapitalization.none,
                    keyboardType: TextInputType.emailAddress,
                    hint: AppTranslations.of(context).text("code"),
                    errorMessage:
                        AppTranslations.of(context).text("error_code"),
                    validating: (String text) => text.isNotEmpty,
                  )
                : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  /// Send a code by email to login the user
  _onAskingLoginCode() async {
    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      EasyLoading.show();

      try {
        await AuthApi.askCodeToLogin(_emailController.text.toLowerCase());
        EasyLoading.dismiss();

        setState(() {
          _isAskingCode = false;
        });
      } catch (e) {
        await EasyLoading.showError(
          AppTranslations.of(context).text("error_server"),
          duration: const Duration(milliseconds: 4000),
          dismissOnTap: true,
        );
      }
    }
  }

  /// Login the user with the email and the code sent to the email
  _onLogin() async {
    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      EasyLoading.show();

      try {
        await AuthApi.login(
            _emailController.text.toLowerCase(), _codeController.text);
        var user = await UserApi.getCurrentUser();

        if (await UserService.exists(user.id)) {
          await UserService.update(user);
        } else {
          await UserService.save(user);
        }

        await Security.setCurrentUser(user);
        EasyLoading.dismiss();

        Navigator.pop(context, true);
      } catch (e) {
        if (e is ApiError) {
          if (e.code == codeErrorVerificationTokenInvalid) {
            await EasyLoading.showError(
              AppTranslations.of(context)
                  .text("error_verification_code_invalid"),
              duration: const Duration(milliseconds: 4000),
              dismissOnTap: true,
            );
          } else {
            await EasyLoading.showError(
              AppTranslations.of(context).text("error_server"),
              duration: const Duration(milliseconds: 4000),
              dismissOnTap: true,
            );
          }
        } else {
          await EasyLoading.showError(
            AppTranslations.of(context).text("error_server"),
            duration: const Duration(milliseconds: 4000),
            dismissOnTap: true,
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();

    _emailFocusNode.dispose();
    _codeFocusNode.dispose();

    _desktopEmailFocusNode.dispose();
    _desktopCodeFocusNode.dispose();

    super.dispose();
  }
}
