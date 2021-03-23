import 'package:chic_secret/localization/app_translations.dart';
import 'package:chic_secret/provider/theme_provider.dart';
import 'package:chic_secret/ui/component/common/chic_elevated_button.dart';
import 'package:chic_secret/ui/component/common/chic_text_button.dart';
import 'package:chic_secret/ui/component/common/chic_text_field.dart';
import 'package:chic_secret/ui/component/common/desktop_modal.dart';
import 'package:chic_secret/utils/chic_platform.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NewPasswordScreen extends StatefulWidget {
  @override
  _NewPasswordScreenState createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  var _nameFocusNode = FocusNode();
  var _usernameFocusNode = FocusNode();
  var _passwordFocusNode = FocusNode();

  var _desktopNameFocusNode = FocusNode();
  var _desktopUsernameFocusNode = FocusNode();
  var _desktopPasswordFocusNode = FocusNode();

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
      title: AppTranslations.of(context).text("new_password"),
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
      appBar: AppBar(
        backgroundColor: themeProvider.secondBackgroundColor,
        brightness: themeProvider.getBrightness(),
        title: Text(AppTranslations.of(context).text("new_category")),
        actions: [
          ChicTextButton(
            child: Text(AppTranslations.of(context).text("save").toUpperCase()),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: _displaysBody(themeProvider),
      ),
    );
  }

  Widget _displaysBody(ThemeProvider themeProvider) {
    return Container(
      margin: EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            ChicTextField(
              controller: _nameController,
              focus: _nameFocusNode,
              desktopFocus: _desktopNameFocusNode,
              nextFocus: _desktopUsernameFocusNode,
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
                _usernameFocusNode.requestFocus();
              },
            ),
            SizedBox(height: 16.0),
            ChicTextField(
              controller: _usernameController,
              focus: _usernameFocusNode,
              desktopFocus: _desktopUsernameFocusNode,
              nextFocus: _desktopPasswordFocusNode,
              autoFocus: false,
              textCapitalization: TextCapitalization.sentences,
              hint: AppTranslations.of(context).text("username_email"),
              errorMessage:
              AppTranslations.of(context).text("error_username_empty"),
              validating: (String text) {
                if (_usernameController.text.isEmpty) {
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
              nextFocus: _desktopPasswordFocusNode,
              autoFocus: false,
              isPassword: true,
              textCapitalization: TextCapitalization.sentences,
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
                _passwordFocusNode.requestFocus();
              },
            ),
            SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();

    _nameFocusNode.dispose();
    _usernameFocusNode.dispose();
    _passwordFocusNode.dispose();

    _desktopNameFocusNode.dispose();
    _desktopUsernameFocusNode.dispose();
    _desktopPasswordFocusNode.dispose();

    super.dispose();
  }
}
