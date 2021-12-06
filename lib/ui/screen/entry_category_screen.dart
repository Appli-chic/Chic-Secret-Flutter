import 'package:chic_secret/localization/app_translations.dart';
import 'package:chic_secret/model/database/category.dart';
import 'package:chic_secret/model/database/entry.dart';
import 'package:chic_secret/provider/theme_provider.dart';
import 'package:chic_secret/service/category_service.dart';
import 'package:chic_secret/service/entry_service.dart';
import 'package:chic_secret/ui/component/common/chic_navigator.dart';
import 'package:chic_secret/ui/component/entry_item.dart';
import 'package:chic_secret/ui/screen/entry_detail_screen.dart';
import 'package:chic_secret/ui/screen/new_category_screen.dart';
import 'package:chic_secret/ui/screen/vaults_screen.dart';
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

  /// Load the list of passwords linked to the current vault and category
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

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(
        backgroundColor: themeProvider.secondBackgroundColor,
        title: Text(widget.category.name),
        actions: [
          IconButton(
            icon: Icon(
              Icons.edit,
              color: themeProvider.textColor,
            ),
            onPressed: _onEditCategory,
          ),
          IconButton(
            icon: Icon(
              Icons.delete,
              color: themeProvider.textColor,
            ),
            onPressed: _onDeletingCategory,
          ),
        ],
      ),
      body: ListView.builder(
        physics: BouncingScrollPhysics(),
        itemCount: _entries.length,
        itemBuilder: (context, index) {
          return EntryItem(
            entry: _entries[index],
            isSelected: false,
            onTap: _onEntrySelected,
          );
        },
      ),
    );
  }

  /// When the entry is selected by the user, it will display the user screen
  _onEntrySelected(Entry entry) async {
    await ChicNavigator.push(context, EntryDetailScreen(entry: entry));
    setState(() {});
  }

  /// Call the [NewCategoryScreen] to edit the selected category
  void _onEditCategory() async {
    var category = await ChicNavigator.push(
      context,
      NewCategoryScreen(category: _category),
      isModal: true,
    );

    if (category != null && category is Category) {
      _category = category;
      _loadPassword();
      widget.onCategoryChanged();
    }
  }

  /// Ask if the category should be deleted and delete it with it's entries
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
