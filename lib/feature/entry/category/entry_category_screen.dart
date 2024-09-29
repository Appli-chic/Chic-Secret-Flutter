import 'dart:io';

import 'package:chic_secret/component/common/chic_navigator.dart';
import 'package:chic_secret/component/entry_item.dart';
import 'package:chic_secret/feature/category/new/new_category_screen.dart';
import 'package:chic_secret/feature/entry/category/entry_category_screen_view_model.dart';
import 'package:chic_secret/feature/entry/detail/entry_detail_screen.dart';
import 'package:chic_secret/localization/app_translations.dart';
import 'package:chic_secret/model/database/category.dart';
import 'package:chic_secret/model/database/entry.dart';
import 'package:chic_secret/provider/theme_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EntryCategoryScreen extends StatefulWidget {
  final Category category;
  final Function() onCategoryChanged;

  EntryCategoryScreen({
    required this.category,
    required this.onCategoryChanged,
  });

  @override
  _EntryCategoryScreenState createState() => _EntryCategoryScreenState();
}

class _EntryCategoryScreenState extends State<EntryCategoryScreen> {
  late EntryCategoryScreenViewModel _viewModel;

  @override
  void initState() {
    _viewModel = EntryCategoryScreenViewModel(widget.category);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context, listen: true);

    return ChangeNotifierProvider<EntryCategoryScreenViewModel>(
      create: (BuildContext context) => _viewModel,
      child: Consumer<EntryCategoryScreenViewModel>(
        builder: (context, value, _) {
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
        },
      ),
    );
  }

  ObstructingPreferredSizeWidget _displaysIosAppbar(
      ThemeProvider themeProvider) {
    return CupertinoNavigationBar(
      previousPageTitle: AppTranslations.of(context).text("categories"),
      backgroundColor: themeProvider.secondBackgroundColor,
      middle: Text(widget.category.name),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _viewModel.category.isTrash
              ? SizedBox.shrink()
              : CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: Icon(CupertinoIcons.pen),
                  onPressed: _onEditCategory,
                ),
          _viewModel.category.isTrash
              ? SizedBox.shrink()
              : CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: Icon(
                    CupertinoIcons.delete,
                    color: Colors.red,
                  ),
                  onPressed: _onDeletingCategory,
                ),
        ],
      ),
    );
  }

  PreferredSizeWidget? _displaysAppbar(ThemeProvider themeProvider) {
    return AppBar(
      backgroundColor: themeProvider.secondBackgroundColor,
      scrolledUnderElevation: 0,
      title: Text(widget.category.name),
      actions: [
        _viewModel.category.isTrash
            ? SizedBox.shrink()
            : IconButton(
                icon: Icon(
                  Icons.edit,
                  color: themeProvider.textColor,
                ),
                onPressed: _onEditCategory,
              ),
        _viewModel.category.isTrash
            ? SizedBox.shrink()
            : IconButton(
                icon: Icon(
                  Icons.delete,
                  color: themeProvider.textColor,
                ),
                onPressed: _onDeletingCategory,
              ),
      ],
    );
  }

  Widget _displayBody() {
    return ListView.builder(
      physics: BouncingScrollPhysics(),
      itemCount: _viewModel.entries.length,
      itemBuilder: (context, index) {
        return EntryItem(
          entry: _viewModel.entries[index],
          isSelected: false,
          onTap: _onEntrySelected,
        );
      },
    );
  }

  _onEntrySelected(Entry entry) async {
    await ChicNavigator.push(
      context,
      EntryDetailScreen(
        entry: entry,
        previousPageTitle: widget.category.name,
      ),
    );
    setState(() {});
  }

  void _onEditCategory() async {
    var category = await ChicNavigator.push(
      context,
      NewCategoryScreen(
        category: _viewModel.category,
        previousPageTitle: widget.category.name,
      ),
      isModal: true,
    );

    if (category != null && category is Category) {
      _viewModel.onEditCategory(category);
      widget.onCategoryChanged();
    }
  }

  void _onDeletingCategory() async {
    var result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppTranslations.of(context).text("warning")),
          content: Text(
            AppTranslations.of(context).textWithArgument(
                "warning_message_delete_category", _viewModel.category.name),
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

    if (result != null && result) {
      await _viewModel.onDeletingCategory();
      Navigator.pop(context, true);
    }
  }
}
