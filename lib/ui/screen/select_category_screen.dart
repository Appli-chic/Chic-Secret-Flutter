import 'dart:io';

import 'package:chic_secret/localization/app_translations.dart';
import 'package:chic_secret/model/database/category.dart';
import 'package:chic_secret/provider/theme_provider.dart';
import 'package:chic_secret/service/category_service.dart';
import 'package:chic_secret/ui/component/category_item.dart';
import 'package:chic_secret/ui/component/common/chic_elevated_button.dart';
import 'package:chic_secret/ui/component/common/chic_text_button.dart';
import 'package:chic_secret/ui/component/common/desktop_modal.dart';
import 'package:chic_secret/ui/screen/vaults_screen.dart';
import 'package:chic_secret/utils/chic_platform.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SelectCategoryScreen extends StatefulWidget {
  final Category? category;
  final bool isShowingTrash;
  final String previousPageTitle;

  SelectCategoryScreen({
    this.category,
    this.isShowingTrash = false,
    required this.previousPageTitle,
  });

  @override
  _SelectCategoryScreenState createState() => _SelectCategoryScreenState();
}

class _SelectCategoryScreenState extends State<SelectCategoryScreen> {
  List<Category> _categories = [];
  Category? _category;

  @override
  void initState() {
    if (widget.category != null) {
      _category = widget.category!;
    }

    _loadCategories();
    super.initState();
  }

  _loadCategories() async {
    if (selectedVault != null) {
      if (widget.isShowingTrash) {
        _categories = await CategoryService.getAllByVault(selectedVault!.id);
      } else {
        _categories =
            await CategoryService.getAllByVaultWithoutTrash(selectedVault!.id);
      }

      setState(() {});
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

  Widget _displaysDesktopInModal(ThemeProvider themeProvider) {
    return DesktopModal(
      title: AppTranslations.of(context).text("select_category"),
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
            child: Text(AppTranslations.of(context).text("done")),
            onPressed: () {
              Navigator.pop(context, _category);
            },
          ),
        ),
      ],
    );
  }

  Widget _displaysMobile(ThemeProvider themeProvider) {
    if (Platform.isIOS) {
      return CupertinoPageScaffold(
        backgroundColor: themeProvider.backgroundColor,
        navigationBar: _displaysIosAppbar(themeProvider),
        child: _displaysBody(themeProvider),
      );
    } else {
      return Scaffold(
        backgroundColor: themeProvider.backgroundColor,
        appBar: _displaysAppbar(themeProvider),
        body: _displaysBody(themeProvider),
      );
    }
  }

  ObstructingPreferredSizeWidget _displaysIosAppbar(
      ThemeProvider themeProvider) {
    return CupertinoNavigationBar(
      previousPageTitle: widget.previousPageTitle,
      backgroundColor: themeProvider.secondBackgroundColor,
      middle: Text(AppTranslations.of(context).text("select_category")),
      trailing: CupertinoButton(
        padding: EdgeInsets.zero,
        child: Text(
          AppTranslations.of(context).text("done"),
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        onPressed: () {
          Navigator.pop(context, _category);
        },
      ),
    );
  }

  PreferredSizeWidget? _displaysAppbar(ThemeProvider themeProvider) {
    return AppBar(
      backgroundColor: themeProvider.secondBackgroundColor,
      title: Text(AppTranslations.of(context).text("select_category")),
      actions: [
        ChicTextButton(
          child: Text(AppTranslations.of(context).text("done")),
          onPressed: () {
            Navigator.pop(context, _category);
          },
        ),
      ],
    );
  }

  Widget _displaysBody(ThemeProvider themeProvider) {
    if (_categories.isEmpty) {
      return ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: desktopHeight,
        ),
        child: Center(
          child: Text(
            AppTranslations.of(context).text("empty_category"),
            style: TextStyle(
              fontSize: 20,
              color: themeProvider.textColor,
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      physics: BouncingScrollPhysics(),
      shrinkWrap: true,
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        return CategoryItem(
          category: _categories[index],
          isSelected:
              _category != null && _category!.id == _categories[index].id,
          isForcingMobileStyle: true,
          onTap: (Category? category) {
            _category = category;
            setState(() {});
          },
        );
      },
    );
  }
}
