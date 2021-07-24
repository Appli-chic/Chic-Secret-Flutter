import 'package:chic_secret/localization/app_translations.dart';
import 'package:chic_secret/model/database/category.dart';
import 'package:chic_secret/model/database/vault.dart';
import 'package:chic_secret/provider/synchronization_provider.dart';
import 'package:chic_secret/provider/theme_provider.dart';
import 'package:chic_secret/service/category_service.dart';
import 'package:chic_secret/service/vault_service.dart';
import 'package:chic_secret/ui/component/common/chic_elevated_button.dart';
import 'package:chic_secret/ui/component/common/chic_text_button.dart';
import 'package:chic_secret/ui/component/common/chic_text_field.dart';
import 'package:chic_secret/ui/component/common/desktop_modal.dart';
import 'package:chic_secret/ui/screen/vaults_screen.dart';
import 'package:chic_secret/utils/chic_platform.dart';
import 'package:chic_secret/utils/constant.dart';
import 'package:chic_secret/utils/security.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class NewVaultScreen extends StatefulWidget {
  final Vault? vault;

  NewVaultScreen({
    this.vault,
  });

  @override
  _NewVaultScreenState createState() => _NewVaultScreenState();
}

class _NewVaultScreenState extends State<NewVaultScreen> {
  late SynchronizationProvider _synchronizationProvider;

  final _formKey = GlobalKey<FormState>();

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

  @override
  void initState() {
    if (widget.vault != null) {
      _nameController = TextEditingController(text: widget.vault!.name);
    }

    super.initState();
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

  /// Displays the screen in a modal for the desktop version
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
            onPressed: _save,
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
        title: Text(AppTranslations.of(context).text("new_vault")),
        actions: [
          ChicTextButton(
            child: Text(AppTranslations.of(context).text("save").toUpperCase()),
            onPressed: _save,
          ),
        ],
      );
    } else {
      return null;
    }
  }

  /// Displays a unified body for both mobile and desktop version
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
              widget.vault == null ? SizedBox(height: 16.0) : SizedBox.shrink(),
              widget.vault == null
                  ? ChicTextField(
                      controller: _passwordController,
                      focus: _passwordFocusNode,
                      desktopFocus: _desktopPasswordFocusNode,
                      nextFocus: _desktopVerifyPasswordFocusNode,
                      hint: AppTranslations.of(context).text("password"),
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
                      hint: AppTranslations.of(context).text("verify_password"),
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
                controller: _usersController,
                focus: _usersFocusNode,
                desktopFocus: _desktopUsersFocusNode,
                textCapitalization: TextCapitalization.characters,
                hint: AppTranslations.of(context).text("users_email"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Save or update a vault in the local database
  _save() async {
    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      var user = await Security.getCurrentUser();
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
          userId: user != null ? user.id : null,
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
