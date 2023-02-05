import 'dart:io';

import 'package:chic_secret/component/common/chic_navigator.dart';
import 'package:chic_secret/component/entry_item.dart';
import 'package:chic_secret/localization/app_translations.dart';
import 'package:chic_secret/model/database/category.dart';
import 'package:chic_secret/model/database/entry.dart';
import 'package:chic_secret/provider/theme_provider.dart';
import 'package:chic_secret/service/category_service.dart';
import 'package:chic_secret/service/entry_service.dart';
import 'package:chic_secret/ui/screen/entry_detail_screen.dart';
import 'package:chic_secret/features/category/new/new_category_screen.dart';
import 'package:chic_secret/utils/shared_data.dart';
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
  List<Entry> _entries = [];
  late Category _category;

  @override
  void initState() {
    _category = widget.category;
    _loadPassword();
    super.initState();
  }

  _loadPassword() async {
    if (selectedVault != null) {
      _entries = await EntryService.getAllByVault(selectedVault!.id,
          categoryId: widget.category.id);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context, listen: true);

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
      previousPageTitle: AppTranslations.of(context).text("categories"),
      backgroundColor: themeProvider.secondBackgroundColor,
      middle: Text(widget.category.name),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _category.isTrash
              ? SizedBox.shrink()
              : CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: Icon(CupertinoIcons.pen),
                  onPressed: _onEditCategory,
                ),
          _category.isTrash
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
      title: Text(widget.category.name),
      actions: [
        _category.isTrash
            ? SizedBox.shrink()
            : IconButton(
                icon: Icon(
                  Icons.edit,
                  color: themeProvider.textColor,
                ),
                onPressed: _onEditCategory,
              ),
        _category.isTrash
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
      itemCount: _entries.length,
      itemBuilder: (context, index) {
        return EntryItem(
          entry: _entries[index],
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
        category: _category,
        previousPageTitle: widget.category.name,
      ),
      isModal: true,
    );

    if (category != null && category is Category) {
      _category = category;
      _loadPassword();
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
                "warning_message_delete_category", _category.name),
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
      // Delete the category and put the linked entries into the trash category
      await EntryService.moveToTrashAllEntriesFromCategory(_category);
      await CategoryService.delete(_category);
      Navigator.pop(context, true);
    }
  }
}
