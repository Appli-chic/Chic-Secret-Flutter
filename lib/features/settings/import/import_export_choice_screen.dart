import 'dart:io';

import 'package:chic_secret/component/common/chic_elevated_button.dart';
import 'package:chic_secret/component/common/chic_navigator.dart';
import 'package:chic_secret/component/common/desktop_modal.dart';
import 'package:chic_secret/component/setting_item.dart';
import 'package:chic_secret/localization/app_translations.dart';
import 'package:chic_secret/provider/synchronization_provider.dart';
import 'package:chic_secret/provider/theme_provider.dart';
import 'package:chic_secret/service/category_service.dart';
import 'package:chic_secret/service/entry_service.dart';
import 'package:chic_secret/utils/chic_platform.dart';
import 'package:chic_secret/utils/import_export.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';

import 'import_screen.dart';

class ImportExportChoiceScreen extends StatefulWidget {
  final Function()? onDataChanged;

  const ImportExportChoiceScreen({
    this.onDataChanged,
  });

  @override
  _ImportExportChoiceScreenState createState() =>
      _ImportExportChoiceScreenState();
}

class _ImportExportChoiceScreenState extends State<ImportExportChoiceScreen> {
  late SynchronizationProvider _synchronizationProvider;

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
      previousPageTitle: AppTranslations.of(context).text("settings"),
      backgroundColor: themeProvider.secondBackgroundColor,
      middle: Text(AppTranslations.of(context).text("import_export")),
    );
  }

  PreferredSizeWidget? _displaysAppbar(ThemeProvider themeProvider) {
    return AppBar(
      backgroundColor: themeProvider.secondBackgroundColor,
      title: Text(AppTranslations.of(context).text("import_export")),
    );
  }

  Widget _displaysBody(ThemeProvider themeProvider) {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Column(
        children: [
          SettingItem(
            title: AppTranslations.of(context).text("import_buttercup"),
            onTap: _importDataFromButtercup,
          ),
          SettingItem(
            title: AppTranslations.of(context).text("import_chic_secret"),
            onTap: _importDataFromChicSecret,
          ),
          SettingItem(
            title: AppTranslations.of(context).text("export"),
            onTap: _exportData,
          ),
        ],
      ),
    );
  }

  _exportData() async {
    EasyLoading.show();

    try {
      await exportVaultData();
      Navigator.pop(context);
    } catch(e) {
      print(e);
    }

    EasyLoading.dismiss();
  }

  _importDataFromChicSecret() async {
    EasyLoading.show();

    try {
      var data = await importFromFile(ImportType.ChicSecret);

      if (data != null) {
        for(var category in data.categories) {
          await CategoryService.save(category);
        }

        for(var entry in data.entries) {
          await EntryService.save(entry);
        }

        if (widget.onDataChanged != null) {
          widget.onDataChanged!();
        }

        _synchronizationProvider.synchronize(isFullSynchronization: true);

        Navigator.pop(context, true);
      }
    } catch (e) {
      print(e);
    }

    EasyLoading.dismiss();
  }

  _importDataFromButtercup() async {
    var data = await importFromFile(ImportType.Buttercup);

    if (data != null) {
      await ChicNavigator.push(
        context,
        ImportScreen(importData: data),
        isModal: true,
      );

      if (widget.onDataChanged != null) {
        widget.onDataChanged!();
      }

      _synchronizationProvider.synchronize(isFullSynchronization: true);

      if (ChicPlatform.isDesktop()) {
        Navigator.pop(context, true);
      }
    }
  }
}
