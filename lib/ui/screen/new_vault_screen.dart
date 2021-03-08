import 'package:chic_secret/localization/app_translations.dart';
import 'package:chic_secret/provider/theme_provider.dart';
import 'package:chic_secret/ui/component/common/chic_elevated_button.dart';
import 'package:chic_secret/ui/component/common/chic_text_button.dart';
import 'package:chic_secret/ui/component/common/chic_text_field.dart';
import 'package:chic_secret/ui/component/common/desktop_modal.dart';
import 'package:chic_secret/utils/chic_platform.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NewVaultScreen extends StatefulWidget {
  @override
  _NewVaultScreenState createState() => _NewVaultScreenState();
}

class _NewVaultScreenState extends State<NewVaultScreen> {
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _verifyPasswordController = TextEditingController();

  var _nameFocusNode = FocusNode();
  var _passwordFocusNode = FocusNode();
  var _verifyPasswordFocusNode = FocusNode();

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
            onPressed: () {},
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
            onPressed: () {},
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ChicTextField(
            controller: _nameController,
            focus: _nameFocusNode,
            autoFocus: true,
            textCapitalization: TextCapitalization.sentences,
            hint: AppTranslations.of(context).text("name"),
            onSubmitted: (String text) {
              _passwordFocusNode.requestFocus();
            },
          ),
          SizedBox(height: 16.0),
          ChicTextField(
            controller: _passwordController,
            focus: _passwordFocusNode,
            hint: AppTranslations.of(context).text("password"),
            isPassword: true,
            onSubmitted: (String text) {
              _verifyPasswordFocusNode.requestFocus();
            },
          ),
          SizedBox(height: 16.0),
          ChicTextField(
            controller: _verifyPasswordController,
            focus: _verifyPasswordFocusNode,
            textInputAction: TextInputAction.done,
            hint: AppTranslations.of(context).text("verify_password"),
            isPassword: true,
            onSubmitted: (String text) {},
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
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    _verifyPasswordController.dispose();

    _nameFocusNode.dispose();
    _passwordFocusNode.dispose();
    _verifyPasswordFocusNode.dispose();
    super.dispose();
  }
}
