import 'dart:io';

import 'package:chic_secret/localization/app_translations.dart';
import 'package:chic_secret/model/database/category.dart';
import 'package:chic_secret/provider/theme_provider.dart';
import 'package:chic_secret/service/category_service.dart';
import 'package:chic_secret/ui/component/category_item.dart';
import 'package:chic_secret/ui/component/common/chic_navigator.dart';
import 'package:chic_secret/ui/screen/entry_category_screen.dart';
import 'package:chic_secret/ui/screen/new_category_screen.dart';
import 'package:chic_secret/features/vault/vaults_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CategoryScreenController {
  void Function()? reloadCategories;

  CategoryScreenController({
    this.reloadCategories,
  });
}

class CategoriesScreen extends StatefulWidget {
  final CategoryScreenController? categoryScreenController;
  final Function() onCategoriesChanged;

  const CategoriesScreen({
    this.categoryScreenController,
    required this.onCategoriesChanged,
  });

  @override
  _CategoriesScreenState createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen>
    with AutomaticKeepAliveClientMixin<CategoriesScreen> {
  List<Category> _categories = [];

  @override
  void initState() {
    if (widget.categoryScreenController != null) {
      widget.categoryScreenController!.reloadCategories = _loadCategories;
    }

    _loadCategories();
    super.initState();
  }

  _loadCategories() async {
    if (selectedVault != null) {
      _categories = await CategoryService.getAllByVault(selectedVault!.id);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var themeProvider = Provider.of<ThemeProvider>(context, listen: true);

    return _displayScaffold(themeProvider);
  }

  Widget _displayScaffold(ThemeProvider themeProvider) {
    if (Platform.isIOS) {
      return CupertinoPageScaffold(
        backgroundColor: themeProvider.backgroundColor,
        navigationBar: _displaysIosAppbar(themeProvider),
        child: _displayBody(),
      );
    } else {
      return Scaffold(
        backgroundColor: themeProvider.backgroundColor,
        appBar: _displaysAppbar(themeProvider),
        body: _displayBody(),
      );
    }
  }

  ObstructingPreferredSizeWidget _displaysIosAppbar(
      ThemeProvider themeProvider) {
    return CupertinoNavigationBar(
      previousPageTitle: AppTranslations.of(context).text("vaults"),
      backgroundColor: themeProvider.secondBackgroundColor,
      middle: Text(AppTranslations.of(context).text("categories")),
      trailing: CupertinoButton(
        padding: EdgeInsets.zero,
        alignment: Alignment.centerRight,
        child: Icon(CupertinoIcons.add),
        onPressed: _onAddCategoryClicked,
      ),
    );
  }

  PreferredSizeWidget? _displaysAppbar(ThemeProvider themeProvider) {
    return AppBar(
      backgroundColor: themeProvider.secondBackgroundColor,
      title: Text(AppTranslations.of(context).text("categories")),
      actions: [
        IconButton(
          icon: Icon(
            Icons.add,
            color: themeProvider.textColor,
          ),
          onPressed: _onAddCategoryClicked,
        )
      ],
    );
  }

  Widget _displayBody() {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      child: ListView.builder(
        physics: BouncingScrollPhysics(),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          return CategoryItem(
            category: _categories[index],
            onTap: (Category? category) async {
              if (category != null) {
                var isDeleted = await ChicNavigator.push(
                  context,
                  EntryCategoryScreen(
                    category: category,
                    onCategoryChanged: () {
                      _loadCategories();
                      widget.onCategoriesChanged();
                    },
                  ),
                  isModal: true,
                );

                if (isDeleted != null && isDeleted) {
                  _loadCategories();
                }
              }
            },
          );
        },
      ),
    );
  }

  _onAddCategoryClicked() async {
    var data = await ChicNavigator.push(
      context,
      NewCategoryScreen(
        previousPageTitle: AppTranslations.of(context).text("categories"),
      ),
      isModal: true,
    );

    if (data != null) {
      _loadCategories();
    }
  }

  @override
  bool get wantKeepAlive => true;
}
