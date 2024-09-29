import 'dart:io';

import 'package:chic_secret/component/common/chic_navigator.dart';
import 'package:chic_secret/component/entry_item.dart';
import 'package:chic_secret/feature/security/entries/security_entries_screen_view_model.dart';
import 'package:chic_secret/localization/app_translations.dart';
import 'package:chic_secret/model/database/entry.dart';
import 'package:chic_secret/provider/theme_provider.dart';
import 'package:chic_secret/feature/entry/detail/entry_detail_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SecurityEntriesScreen extends StatefulWidget {
  final String title;
  final int securityIndex;

  const SecurityEntriesScreen({
    required this.title,
    required this.securityIndex,
  });

  @override
  _SecurityEntriesScreenState createState() => _SecurityEntriesScreenState();
}

class _SecurityEntriesScreenState extends State<SecurityEntriesScreen> {
  late SecurityEntriesScreenViewModel _viewModel;

  @override
  void initState() {
    _viewModel = SecurityEntriesScreenViewModel(widget.securityIndex);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context, listen: true);

    return ChangeNotifierProvider<SecurityEntriesScreenViewModel>(
      create: (BuildContext context) => _viewModel,
      child: Consumer<SecurityEntriesScreenViewModel>(
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
      previousPageTitle: AppTranslations.of(context).text("security"),
      backgroundColor: themeProvider.secondBackgroundColor,
      middle: Text(widget.title),
    );
  }

  PreferredSizeWidget? _displaysAppbar(ThemeProvider themeProvider) {
    return AppBar(
      backgroundColor: themeProvider.secondBackgroundColor,
      scrolledUnderElevation: 0,
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
          itemCount: _viewModel.entries.length,
          itemBuilder: (context, index) {
            return EntryItem(
              entry: _viewModel.entries[index],
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

    _viewModel.checkPasswordSecurity();
  }
}
