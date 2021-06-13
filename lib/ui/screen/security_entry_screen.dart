import 'package:chic_secret/model/database/entry.dart';
import 'package:chic_secret/provider/theme_provider.dart';
import 'package:chic_secret/ui/component/common/chic_navigator.dart';
import 'package:chic_secret/ui/component/entry_item.dart';
import 'package:chic_secret/ui/screen/entry_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SecurityEntryScreen extends StatefulWidget {
  final String title;

  const SecurityEntryScreen({
    required this.title,
  });

  @override
  _SecurityEntryScreenState createState() => _SecurityEntryScreenState();
}

class _SecurityEntryScreenState extends State<SecurityEntryScreen> {
  List<Entry> _entries = [];

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context, listen: true);

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(
        backgroundColor: themeProvider.secondBackgroundColor,
        brightness: themeProvider.getBrightness(),
        title: Text(widget.title),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Container(
          margin: EdgeInsets.only(bottom: 8),
          child: ListView.builder(
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
        ),
      ),
    );
  }

  /// When the entry is selected by the user, it will display the user screen
  _onEntrySelected(Entry entry) async {
    await ChicNavigator.push(context, EntryDetailScreen(entry: entry));

    setState(() {});
  }
}
