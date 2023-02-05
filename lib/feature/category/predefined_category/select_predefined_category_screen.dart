import 'dart:io';

import 'package:chic_secret/component/category_item.dart';
import 'package:chic_secret/component/common/chic_elevated_button.dart';
import 'package:chic_secret/component/common/chic_text_button.dart';
import 'package:chic_secret/component/common/desktop_modal.dart';
import 'package:chic_secret/localization/app_translations.dart';
import 'package:chic_secret/model/database/category.dart';
import 'package:chic_secret/provider/theme_provider.dart';
import 'package:chic_secret/utils/chic_platform.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'select_predefined_category_screen_view_model.dart';

class SelectPredefinedScreenCategory extends StatefulWidget {
  final Category? category;

  SelectPredefinedScreenCategory({this.category});

  @override
  _SelectPredefinedScreenCategoryState createState() =>
      _SelectPredefinedScreenCategoryState();
}

class _SelectPredefinedScreenCategoryState
    extends State<SelectPredefinedScreenCategory> {
  late SelectPredefinedScreenCategoryViewModel _viewModel;

  @override
  void initState() {
    _viewModel = SelectPredefinedScreenCategoryViewModel(widget.category);
    _viewModel.generatePredefinedCategories(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context, listen: true);

    return ChangeNotifierProvider<SelectPredefinedScreenCategoryViewModel>(
      create: (BuildContext context) => _viewModel,
      child: Consumer<SelectPredefinedScreenCategoryViewModel>(
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
      title: AppTranslations.of(context).text("predefined_categories"),
      body: _displayBody(themeProvider),
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
              Navigator.pop(context, _viewModel.category);
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
        child: _displayBody(themeProvider),
      );
    } else {
      return Scaffold(
        backgroundColor: themeProvider.backgroundColor,
        appBar: _displaysAppbar(themeProvider),
        body: _displayBody(themeProvider),
      );
    }
  }

  ObstructingPreferredSizeWidget _displaysIosAppbar(
      ThemeProvider themeProvider) {
    return CupertinoNavigationBar(
      previousPageTitle: AppTranslations.of(context).text("new_category"),
      backgroundColor: themeProvider.secondBackgroundColor,
      middle: Text(AppTranslations.of(context).text("select_category")),
      trailing: CupertinoButton(
        padding: EdgeInsets.zero,
        child: Text(
          AppTranslations.of(context).text("done"),
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        onPressed: () {
          Navigator.pop(context, _viewModel.category);
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
            Navigator.pop(context, _viewModel.category);
          },
        ),
      ],
    );
  }

  Widget _displayBody(ThemeProvider themeProvider) {
    if (_viewModel.predefinedCategories.isEmpty) {
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
      itemCount: _viewModel.predefinedCategories.length,
      itemBuilder: (context, index) {
        return CategoryItem(
          category: _viewModel.predefinedCategories[index],
          isSelected: _viewModel.category != null &&
              _viewModel.category!.id == _viewModel.predefinedCategories[index].id,
          isForcingMobileStyle: true,
          onTap: _viewModel.onSelectCategory,
        );
      },
    );
  }
}
