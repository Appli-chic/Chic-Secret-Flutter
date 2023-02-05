import 'dart:io';

import 'package:chic_secret/component/common/chic_elevated_button.dart';
import 'package:chic_secret/component/common/chic_navigator.dart';
import 'package:chic_secret/component/common/desktop_modal.dart';
import 'package:chic_secret/component/setting_item.dart';
import 'package:chic_secret/features/settings/settings_screen_view_model.dart';
import 'package:chic_secret/features/user/user_screen.dart';
import 'package:chic_secret/localization/app_translations.dart';
import 'package:chic_secret/provider/synchronization_provider.dart';
import 'package:chic_secret/provider/theme_provider.dart';
import 'package:chic_secret/service/category_service.dart';
import 'package:chic_secret/service/custom_field_service.dart';
import 'package:chic_secret/service/entry_service.dart';
import 'package:chic_secret/service/entry_tag_service.dart';
import 'package:chic_secret/service/tag_service.dart';
import 'package:chic_secret/service/vault_service.dart';
import 'package:chic_secret/service/vault_user_service.dart';
import 'package:chic_secret/features/settings/biometry/biometry_screen.dart';
import 'package:chic_secret/features/settings/import/import_export_choice_screen.dart';
import 'package:chic_secret/utils/chic_platform.dart';
import 'package:chic_secret/utils/shared_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  final Function()? onDataChanged;
  final bool hasVaultLinked;

  SettingsScreen({
    this.onDataChanged,
    this.hasVaultLinked = false,
  });

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late SettingsScreenViewModel _viewModel;

  late SynchronizationProvider _synchronizationProvider;
  late AnimationController _synchronizingAnimationController;

  @override
  void initState() {
    _viewModel = SettingsScreenViewModel(widget.onDataChanged);
    _synchronizingAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    super.initState();
  }

  _startsAnimatingSynchronisation() {
    if (!_synchronizingAnimationController.isAnimating) {
      _synchronizingAnimationController.forward();
      _synchronizingAnimationController.repeat();
    }
  }

  _stopAnimatingSynchronisation() {
    _synchronizingAnimationController.stop();
  }

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context, listen: true);
    _synchronizationProvider =
        Provider.of<SynchronizationProvider>(context, listen: true);

    // Starts and stop the synchronization animation
    if (_synchronizationProvider.isSynchronizing) {
      _startsAnimatingSynchronisation();
    } else {
      _stopAnimatingSynchronisation();
    }

    return ChangeNotifierProvider<SettingsScreenViewModel>(
      create: (BuildContext context) => _viewModel,
      child: Consumer<SettingsScreenViewModel>(
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
      title: AppTranslations.of(context).text("settings"),
      body: _displaysBody(themeProvider),
      actions: [
        Container(
          margin: EdgeInsets.only(right: 8, bottom: 8),
          child: ChicElevatedButton(
            child: Text(AppTranslations.of(context).text("ok")),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
      ],
    );
  }

  Widget _displaysMobile(ThemeProvider themeProvider) {
    var body = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: _displaysBody(themeProvider),
      ),
    );

    if (Platform.isIOS) {
      return CupertinoPageScaffold(
        backgroundColor: themeProvider.backgroundColor,
        navigationBar: _displaysIosAppbar(themeProvider),
        child: body,
      );
    } else {
      return Scaffold(
        backgroundColor: themeProvider.backgroundColor,
        appBar: _displaysAppbar(themeProvider),
        body: body,
      );
    }
  }

  ObstructingPreferredSizeWidget _displaysIosAppbar(
      ThemeProvider themeProvider) {
    return CupertinoNavigationBar(
      previousPageTitle: AppTranslations.of(context).text("vaults"),
      backgroundColor: themeProvider.secondBackgroundColor,
      middle: Text(AppTranslations.of(context).text("settings")),
    );
  }

  PreferredSizeWidget? _displaysAppbar(ThemeProvider themeProvider) {
    return AppBar(
      backgroundColor: themeProvider.secondBackgroundColor,
      title: Text(AppTranslations.of(context).text("settings")),
    );
  }

  Widget _displaysBody(ThemeProvider themeProvider) {
    String? lastSyncDate;

    // Get last date synchronization
    if (_synchronizationProvider.lastSyncDate != null) {
      var locale = AppTranslations.of(context).locale;
      var time = DateFormat.Hm(locale.languageCode)
          .format(_synchronizationProvider.lastSyncDate!);

      var date = DateFormat.yMMMMEEEEd(locale.languageCode)
          .format(_synchronizationProvider.lastSyncDate!);

      lastSyncDate = "$time - $date";
    }

    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Column(
        children: [
          _viewModel.user != null
              ? SettingItem(
                  leading: Platform.isIOS
                      ? CupertinoIcons.person_fill
                      : Icons.person,
                  title: _viewModel.user!.email,
                  onTap: _onUserClicked,
                )
              : SettingItem(
                  leading: Platform.isIOS
                      ? CupertinoIcons.square_arrow_right
                      : Icons.login,
                  title: AppTranslations.of(context).text("login"),
                  onTap: () {
                    _viewModel.login(context, _synchronizationProvider);
                  },
                ),
          _viewModel.user != null
              ? SettingItem(
                  leadingIcon: RotationTransition(
                    turns: Tween(begin: 1.0, end: 0.0)
                        .animate(_synchronizingAnimationController),
                    child: Icon(
                        Platform.isIOS
                            ? CupertinoIcons.arrow_2_circlepath
                            : Icons.sync,
                        color: themeProvider.textColor),
                  ),
                  title: AppTranslations.of(context).text("synchronizing"),
                  subtitle: lastSyncDate,
                  onTap: () {
                    _viewModel.synchronize(_synchronizationProvider);
                  },
                )
              : SizedBox.shrink(),
          selectedVault != null
              ? SettingItem(
                  leading: Platform.isIOS
                      ? CupertinoIcons.arrow_up_arrow_down
                      : Icons.import_export_outlined,
                  title: AppTranslations.of(context).text("import_export"),
                  onTap: _goToImportExportScreen,
                )
              : SizedBox.shrink(),
          !ChicPlatform.isDesktop() &&
                  _viewModel.isBiometricsSupported &&
                  widget.hasVaultLinked
              ? SettingItem(
                  leading: Icons.fingerprint,
                  title: AppTranslations.of(context).text("biometry"),
                  onTap: _onBiometryClicked,
                )
              : SizedBox.shrink(),
          widget.hasVaultLinked && selectedVault != null
              ? SettingItem(
                  leading: Platform.isIOS ? CupertinoIcons.pen : Icons.edit,
                  title: AppTranslations.of(context).text("edit_vault"),
                  onTap: () {
                    _viewModel.onEditVaultClicked(context);
                  },
                )
              : SizedBox.shrink(),
          selectedVault != null &&
                  _viewModel.user != null &&
                  selectedVault!.userId == _viewModel.user!.id
              ? SettingItem(
                  backgroundColor: Colors.red[500],
                  tint: ChicPlatform.isDesktop() ? Colors.red[500] : null,
                  leading: Platform.isIOS
                      ? CupertinoIcons.delete
                      : Icons.delete_forever,
                  title: AppTranslations.of(context).text("delete"),
                  onTap: _delete,
                )
              : SizedBox.shrink(),
        ],
      ),
    );
  }

  _delete() async {
    if (selectedVault != null && selectedVault!.userId == _viewModel.user!.id) {
      // Check if the user is willing to delete the vault
      var toDelete = await _displaysDialogSureToDelete();
      if (toDelete) {
        // Delete all the data
        EasyLoading.show();

        try {
          await VaultUserService.deleteFromVault(selectedVault!.id);
          await EntryTagService.deleteAllFromVault(selectedVault!.id);
          await TagService.deleteAllFromVault(selectedVault!.id);
          await CustomFieldService.deleteAllFromVault(selectedVault!.id);
          await CategoryService.deleteAllFromVault(selectedVault!.id);
          await EntryService.deleteAllFromVault(selectedVault!.id);
          await VaultService.delete(selectedVault!);

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
                  "warning_message_delete_vault", selectedVault!.name),
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

  _goToImportExportScreen() async {
    await ChicNavigator.push(
      context,
      ImportExportChoiceScreen(onDataChanged: widget.onDataChanged),
      isModal: true,
    );
  }

  _onBiometryClicked() async {
    await ChicNavigator.push(
      context,
      BiometryScreen(),
    );
  }

  _onUserClicked() async {
    final hasChanged = await ChicNavigator.push(
      context,
      UserScreen(),
      isModal: true,
    );

    if (hasChanged != null && hasChanged) {
      _viewModel.loggedOut();
    }
  }
}
