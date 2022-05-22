import 'dart:io';

import 'package:chic_secret/localization/app_translations.dart';
import 'package:chic_secret/model/database/entry.dart';
import 'package:chic_secret/provider/theme_provider.dart';
import 'package:chic_secret/ui/component/common/chic_navigator.dart';
import 'package:chic_secret/ui/component/entry_item.dart';
import 'package:chic_secret/ui/screen/entry_detail_screen.dart';
import 'package:chic_secret/utils/security.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SecurityEntryScreen extends StatefulWidget {
  final String title;
  final int securityIndex;

  const SecurityEntryScreen({
    required this.title,
    required this.securityIndex,
  });

  @override
  _SecurityEntryScreenState createState() => _SecurityEntryScreenState();
}

class _SecurityEntryScreenState extends State<SecurityEntryScreen> {
  List<Entry> _entries = [];

  @override
  void initState() {
    _checkPasswordSecurity();
    super.initState();
  }

  _checkPasswordSecurity() async {
    var data = await Security.retrievePasswordsSecurityInfo();

    switch (widget.securityIndex) {
      case 1:
        _entries = data.item1;
        break;
      case 2:
        _entries = data.item2;
        break;
      case 3:
        _entries = data.item3;
        break;
      default:
        _entries = data.item1;
        break;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
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
      previousPageTitle: AppTranslations.of(context).text("security"),
      backgroundColor: themeProvider.secondBackgroundColor,
      middle: Text(widget.title),
    );
  }

  PreferredSizeWidget? _displaysAppbar(ThemeProvider themeProvider) {
    return AppBar(
      backgroundColor: themeProvider.secondBackgroundColor,
      title: Text(widget.title),
    );
  }

  Widget _displayBody() {
    return GestureDetector(
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
    );
  }

  _onEntrySelected(Entry entry) async {
    await ChicNavigator.push(
      context,
      EntryDetailScreen(
        entry: entry,
        previousPageTitle: widget.title,
      ),
    );
    _checkPasswordSecurity();
  }
}
