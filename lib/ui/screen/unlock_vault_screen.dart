import 'package:chic_secret/localization/app_translations.dart';
import 'package:chic_secret/model/database/vault.dart';
import 'package:chic_secret/provider/theme_provider.dart';
import 'package:chic_secret/ui/component/common/chic_elevated_button.dart';
import 'package:chic_secret/ui/component/common/chic_text_button.dart';
import 'package:chic_secret/ui/component/common/chic_text_field.dart';
import 'package:chic_secret/ui/component/common/desktop_modal.dart';
import 'package:chic_secret/utils/chic_platform.dart';
import 'package:chic_secret/utils/constant.dart';
import 'package:chic_secret/utils/security.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:local_auth/local_auth.dart';

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
  final LocalAuthentication auth = LocalAuthentication();
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();

  var _passwordFocusNode = FocusNode();
  var _desktopPasswordFocusNode = FocusNode();

  var _isPasswordIncorrect = false;

  @override
  void initState() {
    _unlockWithBiometry();

    super.initState();
  }

  /// Unlock the vault with Face ID or fingerprint
  _unlockWithBiometry() async {
    var isUsingBiometry =
        await Security.isPasswordSavedForBiometry(widget.vault);

    if (widget.isUnlocking && isUsingBiometry) {
      bool canCheckBiometrics = await auth.canCheckBiometrics;

      if (canCheckBiometrics) {
        try {
          bool didAuthenticate = await auth.authenticate(
            localizedReason:
                AppTranslations.of(context).text("authenticate_to_unlock"),
          );

          if (didAuthenticate) {
            var password = await Security.getPasswordFromBiometry(widget.vault);

            if (password != null) {
              Navigator.pop(context, password);
            }
          }
        } catch (e) {
          print(e);
        }
      }
    }
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

  /// Displays the screen in a modal for the desktop version
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
            onPressed: _unlockVault,
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
        title: Text(AppTranslations.of(context).text("unlock_vault")),
        actions: [
          ChicTextButton(
            child:
                Text(AppTranslations.of(context).text("unlock").toUpperCase()),
            onPressed: _unlockVault,
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
              controller: _passwordController,
              focus: _passwordFocusNode,
              desktopFocus: _desktopPasswordFocusNode,
              autoFocus: true,
              isPassword: true,
              textInputAction: TextInputAction.done,
              hint: AppTranslations.of(context).text("password"),
              errorMessage:
                  AppTranslations.of(context).text("error_empty_password"),
              validating: (String text) {
                if (_passwordController.text.isEmpty) {
                  return false;
                }

                return true;
              },
              onSubmitted: (String text) {
                _unlockVault();
              },
            ),
            _isPasswordIncorrect && _passwordController.text.isNotEmpty
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

  /// Check if the encrypted signature can be decrypted thanks to the
  /// password. If we find back the right signature then we define
  /// the vault as unlocked.
  _unlockVault() {
    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      try {
        var message =
            Security.decrypt(_passwordController.text, widget.vault.signature);

        if (message == signature) {
          Navigator.pop(context, _passwordController.text);
        } else {
          setState(() {
            _isPasswordIncorrect = true;
          });
        }
      } catch (e) {
        setState(() {
          _isPasswordIncorrect = true;
        });
      }
    }

    setState(() {});
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    _desktopPasswordFocusNode.dispose();

    super.dispose();
  }
}
