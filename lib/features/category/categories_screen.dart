import 'dart:io';

import 'package:chic_secret/features/category/categories_screen_view_model.dart';
import 'package:chic_secret/localization/app_translations.dart';
import 'package:chic_secret/model/database/category.dart';
import 'package:chic_secret/provider/theme_provider.dart';
import 'package:chic_secret/ui/component/category_item.dart';
import 'package:chic_secret/ui/component/common/chic_navigator.dart';
import 'package:chic_secret/ui/screen/entry_category_screen.dart';
import 'package:chic_secret/ui/screen/new_category_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CategoriesScreenController {
  void Function()? reloadCategories;

  CategoriesScreenController({
    this.reloadCategories,
  });
}

class CategoriesScreen extends StatefulWidget {
  final CategoriesScreenController? categoryScreenController;
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
  CategoriesScreenViewModel _viewModel = CategoriesScreenViewModel();

  @override
  void initState() {
    if (widget.categoryScreenController != null) {
      widget.categoryScreenController!.reloadCategories =
          _viewModel.loadCategories();
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var themeProvider = Provider.of<ThemeProvider>(context, listen: true);

    return ChangeNotifierProvider<CategoriesScreenViewModel>(
      create: (BuildContext context) => _viewModel,
      child: Consumer<CategoriesScreenViewModel>(
        builder: (context, value, _) {
          return _displayScaffold(themeProvider);
        },
      ),
    );
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
        itemCount: _viewModel.categories.length,
        itemBuilder: (context, index) {
          return CategoryItem(
            category: _viewModel.categories[index],
            onTap: _onCategoryTapped,
          );
        },
      ),
    );
  }

  _onCategoryTapped(Category? category) async {
    if (category != null) {
      var isDeleted = await ChicNavigator.push(
        context,
        EntryCategoryScreen(
          category: category,
          onCategoryChanged: _onCategoryChanged,
        ),
        isModal: true,
      );

      if (isDeleted != null && isDeleted) {
        _viewModel.loadCategories();
      }
    }
  }

  _onCategoryChanged() {
    _viewModel.loadCategories();
    widget.onCategoriesChanged();
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
      _viewModel.loadCategories();
    }
  }

  @override
  bool get wantKeepAlive => true;
}
