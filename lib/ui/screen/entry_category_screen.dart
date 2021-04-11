import 'package:chic_secret/model/database/category.dart';
import 'package:chic_secret/model/database/entry.dart';
import 'package:chic_secret/provider/theme_provider.dart';
import 'package:chic_secret/service/entry_service.dart';
import 'package:chic_secret/ui/component/common/chic_navigator.dart';
import 'package:chic_secret/ui/component/entry_item.dart';
import 'package:chic_secret/ui/screen/entry_detail_screen.dart';
import 'package:chic_secret/ui/screen/vaults_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EntryCategoryScreen extends StatefulWidget {
  final Category category;

  EntryCategoryScreen({
    required this.category,
  });

  @override
  _EntryCategoryScreenState createState() => _EntryCategoryScreenState();
}

class _EntryCategoryScreenState extends State<EntryCategoryScreen> {
  List<Entry> _entries = [];

  @override
  void initState() {
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
        brightness: themeProvider.getBrightness(),
        title: Text(widget.category.name),
        actions: [],
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
}
