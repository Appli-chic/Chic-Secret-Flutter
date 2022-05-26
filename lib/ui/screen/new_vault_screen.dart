import 'dart:io';

import 'package:chic_secret/api/user_api.dart';
import 'package:chic_secret/localization/app_translations.dart';
import 'package:chic_secret/model/database/category.dart';
import 'package:chic_secret/model/database/user.dart';
import 'package:chic_secret/model/database/vault.dart';
import 'package:chic_secret/model/database/vault_user.dart';
import 'package:chic_secret/provider/synchronization_provider.dart';
import 'package:chic_secret/provider/theme_provider.dart';
import 'package:chic_secret/service/category_service.dart';
import 'package:chic_secret/service/custom_field_service.dart';
import 'package:chic_secret/service/entry_service.dart';
import 'package:chic_secret/service/entry_tag_service.dart';
import 'package:chic_secret/service/tag_service.dart';
import 'package:chic_secret/service/user_service.dart';
import 'package:chic_secret/service/vault_service.dart';
import 'package:chic_secret/service/vault_user_service.dart';
import 'package:chic_secret/ui/component/common/chic_elevated_button.dart';
import 'package:chic_secret/ui/component/common/chic_text_button.dart';
import 'package:chic_secret/ui/component/common/chic_text_field.dart';
import 'package:chic_secret/ui/component/common/desktop_modal.dart';
import 'package:chic_secret/ui/component/tag_chip.dart';
import 'package:chic_secret/ui/screen/vaults_screen.dart';
import 'package:chic_secret/utils/chic_platform.dart';
import 'package:chic_secret/utils/constant.dart';
import 'package:chic_secret/utils/security.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

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
  late SynchronizationProvider _synchronizationProvider;

  final _formKey = GlobalKey<FormState>();
  User? _user;

  var _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _verifyPasswordController = TextEditingController();
  final _usersController = TextEditingController();

  var _nameFocusNode = FocusNode();
  var _passwordFocusNode = FocusNode();
  var _verifyPasswordFocusNode = FocusNode();
  var _usersFocusNode = FocusNode();

  var _desktopNameFocusNode = FocusNode();
  var _desktopPasswordFocusNode = FocusNode();
  var _desktopVerifyPasswordFocusNode = FocusNode();
  var _desktopUsersFocusNode = FocusNode();

  List<String> _emails = [];
  List<User> _users = [];

  @override
  void initState() {
    if (widget.vault != null) {
      _nameController = TextEditingController(text: widget.vault!.name);
      _loadUsers();
    }

    _getUser();

    super.initState();
  }

  _loadUsers() async {
    _users = await UserService.getUsersByVault(widget.vault!.id);

    for (var user in _users) {
      _emails.add(user.email);
    }

    setState(() {});
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
    _synchronizationProvider =
        Provider.of<SynchronizationProvider>(context, listen: true);

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
                label: AppTranslations.of(context).text("name"),
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
              widget.vault == null ? SizedBox(height: 16.0) : SizedBox.shrink(),
              widget.vault == null
                  ? ChicTextField(
                      controller: _passwordController,
                      focus: _passwordFocusNode,
                      desktopFocus: _desktopPasswordFocusNode,
                      nextFocus: _desktopVerifyPasswordFocusNode,
                      label: AppTranslations.of(context).text("password"),
                      isPassword: true,
                      hasStrengthIndicator: true,
                      errorMessage: AppTranslations.of(context)
                          .text("error_small_password"),
                      validating: (String text) =>
                          _passwordController.text.isNotEmpty &&
                          _passwordController.text.length >= 6,
                      onSubmitted: (String text) {
                        _verifyPasswordFocusNode.requestFocus();
                      },
                    )
                  : SizedBox.shrink(),
              widget.vault == null ? SizedBox(height: 16.0) : SizedBox.shrink(),
              widget.vault == null
                  ? ChicTextField(
                      controller: _verifyPasswordController,
                      focus: _verifyPasswordFocusNode,
                      desktopFocus: _desktopVerifyPasswordFocusNode,
                      textInputAction: TextInputAction.done,
                      label:
                          AppTranslations.of(context).text("verify_password"),
                      isPassword: true,
                      errorMessage: AppTranslations.of(context)
                          .text("error_different_password"),
                      validating: (String text) =>
                          _verifyPasswordController.text ==
                          _passwordController.text,
                    )
                  : SizedBox.shrink(),
              widget.vault == null ? SizedBox(height: 16.0) : SizedBox.shrink(),
              widget.vault == null
                  ? Text(
                      AppTranslations.of(context)
                          .text("explanation_master_password"),
                      style: TextStyle(
                        color: themeProvider.secondTextColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w300,
                      ),
                    )
                  : SizedBox.shrink(),
              _user != null ? SizedBox(height: 32.0) : SizedBox.shrink(),
              _user != null
                  ? Text(
                      AppTranslations.of(context).text("share_optional"),
                      style: TextStyle(
                        color: themeProvider.textColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 17,
                      ),
                    )
                  : SizedBox.shrink(),
              _user != null ? SizedBox(height: 16.0) : SizedBox.shrink(),
              _user != null
                  ? ChicTextField(
                      controller: _usersController,
                      focus: _usersFocusNode,
                      desktopFocus: _desktopUsersFocusNode,
                      textCapitalization: TextCapitalization.characters,
                      label: AppTranslations.of(context).text("users_email"),
                      onSubmitted: _checkEmailExists,
                    )
                  : SizedBox.shrink(),
              _user != null ? SizedBox(height: 16.0) : SizedBox.shrink(),
              _user != null
                  ? Wrap(
                      children: _createChipsList(themeProvider),
                    )
                  : SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _createChipsList(ThemeProvider themeProvider) {
    List<Widget> chips = [];

    for (var tagIndex = 0; tagIndex < _emails.length; tagIndex++) {
      chips.add(
        TagChip(
          name: _emails[tagIndex],
          index: tagIndex,
          onDelete: (int index) {
            _emails.removeAt(tagIndex);
            setState(() {});
          },
        ),
      );
    }

    return chips;
  }

  _checkEmailExists(String text) async {
    EasyLoading.show();

    try {
      var user = await UserApi.getUserByEmail(text);

      if (_user != null && _user!.email == text) {
        await EasyLoading.showError(
          AppTranslations.of(context).text("error_user_cant_be_you"),
          duration: const Duration(milliseconds: 4000),
          dismissOnTap: true,
        );
      } else {
        if (user != null) {
          _emails.add(text);
          _usersController.clear();
          setState(() {});
          EasyLoading.dismiss();

          if (await UserService.exists(user.id)) {
            UserService.update(user);
          } else {
            UserService.save(user);
          }
        } else {
          await EasyLoading.showError(
            AppTranslations.of(context).text("error_user_dont_exist"),
            duration: const Duration(milliseconds: 4000),
            dismissOnTap: true,
          );
        }
      }
    } catch (e) {
      print(e);

      await EasyLoading.showError(
        AppTranslations.of(context).text("error_user_dont_exist"),
        duration: const Duration(milliseconds: 4000),
        dismissOnTap: true,
      );
    }
  }

  _delete() async {
    if (widget.vault != null) {
      // Check if the user is willing to delete the vault
      var toDelete = await _displaysDialogSureToDelete();
      if (toDelete) {
        // Delete all the data
        EasyLoading.show();

        try {
          await VaultUserService.deleteFromVault(widget.vault!.id);
          await EntryTagService.deleteAllFromVault(widget.vault!.id);
          await TagService.deleteAllFromVault(widget.vault!.id);
          await CustomFieldService.deleteAllFromVault(widget.vault!.id);
          await CategoryService.deleteAllFromVault(widget.vault!.id);
          await EntryService.deleteAllFromVault(widget.vault!.id);
          await VaultService.delete(widget.vault!);

          selectedVault = null;
          currentPassword = null;
          _synchronizationProvider.synchronize();
        } catch (e) {
          print(e);
        }

        Navigator.pop(context, true);
      }

      EasyLoading.dismiss();
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
        });
  }

  _save() async {
    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      Vault vault;

      if (widget.vault != null) {
        // Update
        vault = widget.vault!;
        vault.name = _nameController.text;
        vault.updatedAt = DateTime.now();

        await VaultService.update(vault);
      } else {
        // Save
        vault = Vault(
          id: Uuid().v4(),
          name: _nameController.text,
          signature: Security.encrypt(_passwordController.text, signature),
          userId: _user != null ? _user!.id : null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await VaultService.save(vault);

        // Create the trash category
        var trashCategory = Category(
          id: Uuid().v4(),
          name: AppTranslations.of(context).text("trash"),
          color: "#fff44336",
          icon: 57785,
          isTrash: true,
          vaultId: vault.id,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Create general category
        var generalCategory = Category(
          id: Uuid().v4(),
          name: AppTranslations.of(context).text("general"),
          color: "#ff2196f3",
          icon: 58136,
          isTrash: false,
          vaultId: vault.id,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await CategoryService.save(trashCategory);
        await CategoryService.save(generalCategory);

        // Select the vault and keep the password in memory
        selectedVault = vault;
        currentPassword = _passwordController.text;
      }

      // Save all the users linked to the vault
      for (var email in _emails) {
        // Check if the user linked to the vault already exist in the database
        var user = await UserService.getUserByEmail(email);

        // Save the Vault user if the user isn't already linked to it
        if (_users.where((u) => u.email == user!.email).isEmpty) {
          var vaultUser = VaultUser(
            vaultId: vault.id,
            userId: user!.id,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          await VaultUserService.save(vaultUser);
        }
      }

      // Delete the tags if they are not linked to the entry anymore
      for (var user in _users) {
        if (_emails.where((u) => u == user.email).isEmpty) {
          await VaultUserService.delete(vault.id, user.id);
        }
      }

      _synchronizationProvider.synchronize();

      Navigator.pop(context, vault);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    _verifyPasswordController.dispose();
    _usersController.dispose();

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
