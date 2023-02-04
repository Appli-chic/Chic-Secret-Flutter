import 'dart:io';

import 'package:chic_secret/features/vault/new/new_vault_screen_view_model.dart';
import 'package:chic_secret/localization/app_translations.dart';
import 'package:chic_secret/model/database/vault.dart';
import 'package:chic_secret/provider/synchronization_provider.dart';
import 'package:chic_secret/provider/theme_provider.dart';
import 'package:chic_secret/ui/component/common/chic_elevated_button.dart';
import 'package:chic_secret/ui/component/common/chic_text_button.dart';
import 'package:chic_secret/ui/component/common/chic_text_field.dart';
import 'package:chic_secret/ui/component/common/desktop_modal.dart';
import 'package:chic_secret/ui/component/tag_chip.dart';
import 'package:chic_secret/utils/chic_platform.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';

class NewVaultScreen extends StatefulWidget {
  final Vault? vault;
  final bool isFromSettings;

  NewVaultScreen({
    this.vault,
    this.isFromSettings = false,
  });

  @override
  _NewVaultScreenState createState() => _NewVaultScreenState();
}

class _NewVaultScreenState extends State<NewVaultScreen> {
  late NewVaultScreenViewModel _viewModel;
  late SynchronizationProvider _synchronizationProvider;

  var _nameFocusNode = FocusNode();
  var _passwordFocusNode = FocusNode();
  var _verifyPasswordFocusNode = FocusNode();
  var _usersFocusNode = FocusNode();

  var _desktopNameFocusNode = FocusNode();
  var _desktopPasswordFocusNode = FocusNode();
  var _desktopVerifyPasswordFocusNode = FocusNode();
  var _desktopUsersFocusNode = FocusNode();

  @override
  void initState() {
    _viewModel = NewVaultScreenViewModel(widget.vault);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context, listen: true);
    _synchronizationProvider =
        Provider.of<SynchronizationProvider>(context, listen: true);

    return ChangeNotifierProvider<NewVaultScreenViewModel>(
      create: (BuildContext context) => _viewModel,
      child: Consumer<NewVaultScreenViewModel>(
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
        widget.vault != null && widget.isFromSettings
            ? Container(
                margin: EdgeInsets.only(right: 8, bottom: 8),
                child: ChicElevatedButton(
                  child: Text(AppTranslations.of(context).text("delete")),
                  backgroundColor: Colors.red,
                  onPressed: _delete,
                ),
              )
            : SizedBox(),
        Container(
          margin: EdgeInsets.only(right: 8, bottom: 8),
          child: ChicElevatedButton(
            child: Text(AppTranslations.of(context).text("save")),
            onPressed: _save,
          ),
        ),
      ],
    );
  }

  Widget _displaysMobile(ThemeProvider themeProvider) {
    if (Platform.isIOS) {
      return CupertinoPageScaffold(
        backgroundColor: themeProvider.backgroundColor,
        navigationBar: _displayIosAppBar(themeProvider),
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

  ObstructingPreferredSizeWidget _displayIosAppBar(
    ThemeProvider themeProvider,
  ) {
    return CupertinoNavigationBar(
      previousPageTitle: AppTranslations.of(context).text("vaults"),
      backgroundColor: themeProvider.secondBackgroundColor,
      middle: Text(AppTranslations.of(context).text("new_vault")),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          widget.vault != null && widget.isFromSettings
              ? CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: Icon(
                    CupertinoIcons.delete,
                    color: Colors.red,
                  ),
                  onPressed: _delete,
                )
              : SizedBox(),
          CupertinoButton(
            padding: EdgeInsets.zero,
            child: Text(
              AppTranslations.of(context).text("save"),
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            onPressed: _save,
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget? _displaysAppbar(ThemeProvider themeProvider) {
    if (!ChicPlatform.isDesktop()) {
      return AppBar(
        backgroundColor: themeProvider.secondBackgroundColor,
        title: Text(AppTranslations.of(context).text("new_vault")),
        actions: [
          widget.vault != null && widget.isFromSettings
              ? IconButton(
                  icon: Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                  onPressed: _delete,
                )
              : SizedBox(),
          ChicTextButton(
            child: Text(AppTranslations.of(context).text("save")),
            onPressed: _save,
          ),
        ],
      );
    } else {
      return null;
    }
  }

  Widget _displaysBody(ThemeProvider themeProvider) {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Container(
        margin: EdgeInsets.all(16),
        child: Form(
          key: _viewModel.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ChicTextField(
                controller: _viewModel.nameController,
                focus: _nameFocusNode,
                desktopFocus: _desktopNameFocusNode,
                nextFocus: _desktopPasswordFocusNode,
                autoFocus: true,
                textCapitalization: TextCapitalization.sentences,
                label: AppTranslations.of(context).text("name"),
                errorMessage:
                    AppTranslations.of(context).text("error_name_empty"),
                validating: (String text) {
                  if (_viewModel.nameController.text.isEmpty) {
                    return false;
                  }

                  return true;
                },
                onSubmitted: (String text) {
                  _passwordFocusNode.requestFocus();
                },
              ),
              _buildCreationForm(themeProvider),
              _buildShareForm(themeProvider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreationForm(ThemeProvider themeProvider) {
    if(widget.vault != null) return SizedBox.shrink();

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16.0),
          ChicTextField(
            controller: _viewModel.passwordController,
            focus: _passwordFocusNode,
            desktopFocus: _desktopPasswordFocusNode,
            nextFocus: _desktopVerifyPasswordFocusNode,
            label: AppTranslations.of(context).text("password"),
            isPassword: true,
            hasStrengthIndicator: true,
            errorMessage: AppTranslations.of(context)
                .text("error_small_password"),
            validating: (String text) =>
            _viewModel.passwordController.text.isNotEmpty &&
                _viewModel.passwordController.text.length >= 6,
            onSubmitted: (String text) {
              _verifyPasswordFocusNode.requestFocus();
            },
          ),
          SizedBox(height: 16.0),
          ChicTextField(
            controller: _viewModel.verifyPasswordController,
            focus: _verifyPasswordFocusNode,
            desktopFocus: _desktopVerifyPasswordFocusNode,
            textInputAction: TextInputAction.done,
            label:
            AppTranslations.of(context).text("verify_password"),
            isPassword: true,
            errorMessage: AppTranslations.of(context)
                .text("error_different_password"),
            validating: (String text) =>
            _viewModel.verifyPasswordController.text ==
                _viewModel.passwordController.text,
          ),
          SizedBox(height: 16.0),
          Text(
            AppTranslations.of(context)
                .text("explanation_master_password"),
            style: TextStyle(
              color: themeProvider.secondTextColor,
              fontSize: 13,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
    );
  }

  Widget _buildShareForm(ThemeProvider themeProvider) {
    if (_viewModel.user == null) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 32.0),
        Text(
          AppTranslations.of(context).text("share_optional"),
          style: TextStyle(
            color: themeProvider.textColor,
            fontWeight: FontWeight.w600,
            fontSize: 17,
          ),
        ),
        SizedBox(height: 16.0),
        ChicTextField(
          controller: _viewModel.usersController,
          focus: _usersFocusNode,
          desktopFocus: _desktopUsersFocusNode,
          textCapitalization: TextCapitalization.characters,
          label: AppTranslations.of(context).text("users_email"),
          onSubmitted: (String text) {
            _viewModel.checkEmailExists(context, text);
          },
        ),
        SizedBox(height: 16.0),
        Wrap(
          children: _createChipsList(themeProvider),
        ),
      ],
    );
  }

  List<Widget> _createChipsList(ThemeProvider themeProvider) {
    List<Widget> chips = [];

    for (var tagIndex = 0; tagIndex < _viewModel.emails.length; tagIndex++) {
      chips.add(
        TagChip(
          name: _viewModel.emails[tagIndex],
          index: tagIndex,
          onDelete: (int index) {
            _viewModel.emails.removeAt(tagIndex);
            setState(() {});
          },
        ),
      );
    }

    return chips;
  }

  _delete() async {
    if (_viewModel.originalVault != null) {
      var toDelete = await _displaysDialogSureToDelete();

      if (toDelete) {
        EasyLoading.show();

        await _viewModel.delete(_synchronizationProvider);
        Navigator.pop(context, true);

        EasyLoading.dismiss();
      }
    } else {
      await EasyLoading.showError(
        AppTranslations.of(context).text("cant_delete_vault_not_owner"),
        duration: const Duration(milliseconds: 4000),
        dismissOnTap: true,
      );
    }
  }

  Future<bool> _displaysDialogSureToDelete() async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppTranslations.of(context).text("warning")),
          content: Text(
            AppTranslations.of(context).textWithArgument(
                "warning_message_delete_vault", widget.vault!.name),
          ),
          actions: [
            TextButton(
              child: Text(
                AppTranslations.of(context).text("cancel"),
              ),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text(
                AppTranslations.of(context).text("delete"),
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  _save() async {
    _viewModel.save(context, _synchronizationProvider);
  }

  @override
  void dispose() {
    _viewModel.nameController.dispose();
    _viewModel.passwordController.dispose();
    _viewModel.verifyPasswordController.dispose();
    _viewModel.usersController.dispose();

    _nameFocusNode.dispose();
    _passwordFocusNode.dispose();
    _verifyPasswordFocusNode.dispose();
    _usersFocusNode.dispose();

    _desktopNameFocusNode.dispose();
    _desktopPasswordFocusNode.dispose();
    _desktopVerifyPasswordFocusNode.dispose();
    _desktopUsersFocusNode.dispose();

    super.dispose();
  }
}
