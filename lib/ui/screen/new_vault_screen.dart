import 'package:chic_secret/localization/app_translations.dart';
import 'package:chic_secret/model/database/vault.dart';
import 'package:chic_secret/provider/theme_provider.dart';
import 'package:chic_secret/service/vault_service.dart';
import 'package:chic_secret/ui/component/common/chic_elevated_button.dart';
import 'package:chic_secret/ui/component/common/chic_text_button.dart';
import 'package:chic_secret/ui/component/common/chic_text_field.dart';
import 'package:chic_secret/ui/component/common/desktop_modal.dart';
import 'package:chic_secret/utils/chic_platform.dart';
import 'package:chic_secret/utils/constant.dart';
import 'package:chic_secret/utils/security.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class NewVaultScreen extends StatefulWidget {
  @override
  _NewVaultScreenState createState() => _NewVaultScreenState();
}

class _NewVaultScreenState extends State<NewVaultScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _verifyPasswordController = TextEditingController();

  var _nameFocusNode = FocusNode();
  var _passwordFocusNode = FocusNode();
  var _verifyPasswordFocusNode = FocusNode();

  var _desktopNameFocusNode = FocusNode();
  var _desktopPasswordFocusNode = FocusNode();
  var _desktopVerifyPasswordFocusNode = FocusNode();

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
      title: AppTranslations.of(context).text("new_vault"),
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
            child: Text(AppTranslations.of(context).text("save")),
            onPressed: _onAddingVault,
          ),
        ),
      ],
    );
  }

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

  PreferredSizeWidget? _displaysAppbar(ThemeProvider themeProvider) {
    if (!ChicPlatform.isDesktop()) {
      return AppBar(
        backgroundColor: themeProvider.secondBackgroundColor,
        brightness: themeProvider.getBrightness(),
        title: Text(AppTranslations.of(context).text("new_vault")),
        actions: [
          ChicTextButton(
            child: Text(AppTranslations.of(context).text("save").toUpperCase()),
            onPressed: _onAddingVault,
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
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ChicTextField(
              controller: _nameController,
              focus: _nameFocusNode,
              desktopFocus: _desktopNameFocusNode,
              nextFocus: _desktopPasswordFocusNode,
              autoFocus: true,
              textCapitalization: TextCapitalization.sentences,
              hint: AppTranslations.of(context).text("name"),
              errorMessage:
                  AppTranslations.of(context).text("error_name_empty"),
              validating: (String text) {
                if (_nameController.text.isEmpty) {
                  return false;
                }

                return true;
              },
              onSubmitted: (String text) {
                _passwordFocusNode.requestFocus();
              },
            ),
            SizedBox(height: 16.0),
            ChicTextField(
              controller: _passwordController,
              focus: _passwordFocusNode,
              desktopFocus: _desktopPasswordFocusNode,
              nextFocus: _desktopVerifyPasswordFocusNode,
              hint: AppTranslations.of(context).text("password"),
              isPassword: true,
              hasStrengthIndicator: true,
              errorMessage:
                  AppTranslations.of(context).text("error_small_password"),
              validating: (String text) {
                if (_passwordController.text.isEmpty ||
                    _passwordController.text.length < 6) {
                  return false;
                }

                return true;
              },
              onSubmitted: (String text) {
                _verifyPasswordFocusNode.requestFocus();
              },
            ),
            SizedBox(height: 16.0),
            ChicTextField(
              controller: _verifyPasswordController,
              focus: _verifyPasswordFocusNode,
              desktopFocus: _desktopVerifyPasswordFocusNode,
              textInputAction: TextInputAction.done,
              hint: AppTranslations.of(context).text("verify_password"),
              isPassword: true,
              errorMessage:
                  AppTranslations.of(context).text("error_different_password"),
              validating: (String text) {
                if (_verifyPasswordController.text !=
                    _passwordController.text) {
                  return false;
                }

                return true;
              },
            ),
            SizedBox(height: 16.0),
            Text(
              AppTranslations.of(context).text("explanation_master_password"),
              style: TextStyle(
                color: themeProvider.secondTextColor,
                fontSize: 13,
                fontWeight: FontWeight.w300,
              ),
            )
          ],
        ),
      ),
    );
  }

  _onAddingVault() async {
    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      var vault = Vault(
        id: Uuid().v4(),
        name: _nameController.text,
        signature: Security.encrypt(_passwordController.text, signature),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      vault = await VaultService.save(vault);
      Navigator.pop(context, vault);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    _verifyPasswordController.dispose();

    _nameFocusNode.dispose();
    _passwordFocusNode.dispose();
    _verifyPasswordFocusNode.dispose();

    _desktopNameFocusNode.dispose();
    _desktopPasswordFocusNode.dispose();
    _desktopVerifyPasswordFocusNode.dispose();

    super.dispose();
  }
}
