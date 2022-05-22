import 'dart:io';

import 'package:chic_secret/localization/app_translations.dart';
import 'package:chic_secret/model/database/entry.dart';
import 'package:chic_secret/provider/theme_provider.dart';
import 'package:chic_secret/ui/component/common/chic_navigator.dart';
import 'package:chic_secret/ui/component/entry_item.dart';
import 'package:chic_secret/ui/component/security_item.dart';
import 'package:chic_secret/ui/screen/entry_detail_screen.dart';
import 'package:chic_secret/ui/screen/security_entry_screen.dart';
import 'package:chic_secret/utils/security.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class SecurityScreen extends StatefulWidget {
  final Function()? onDataChanged;

  const SecurityScreen({
    this.onDataChanged,
  });

  @override
  _SecurityScreenState createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  List<Entry> _weakPasswordEntries = [];
  List<Entry> _oldEntries = [];
  List<Entry> _duplicatedEntries = [];
  bool _isLoading = true;

  @override
  void initState() {
    _checkPasswordSecurity();
    super.initState();
  }

  _checkPasswordSecurity() async {
    var data = await Security.retrievePasswordsSecurityInfo();

    _weakPasswordEntries = data.item1;
    _oldEntries = data.item2;
    _duplicatedEntries = data.item3;
    _isLoading = false;
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
      previousPageTitle: AppTranslations.of(context).text("vaults"),
      backgroundColor: themeProvider.secondBackgroundColor,
      middle: Text(AppTranslations.of(context).text("security")),
    );
  }

  PreferredSizeWidget? _displaysAppbar(ThemeProvider themeProvider) {
    return AppBar(
      backgroundColor: themeProvider.secondBackgroundColor,
      title: Text(AppTranslations.of(context).text("security")),
    );
  }

  Widget _displayBody(ThemeProvider themeProvider) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Container(
        margin: EdgeInsets.only(top: 16),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(left: 16, right: 16),
              child: Row(
                children: [
                  Expanded(
                    child: SecurityItem(
                      securityIndex: 1,
                      number: _weakPasswordEntries.length,
                      title: AppTranslations.of(context).text("weak"),
                      icon: Platform.isIOS
                          ? CupertinoIcons.pencil_ellipsis_rectangle
                          : Icons.password,
                      color: Colors.red,
                      onTap: _onSecurityItemClicked,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: SecurityItem(
                      securityIndex: 2,
                      number: _oldEntries.length,
                      title: AppTranslations.of(context).text("old"),
                      icon: Platform.isIOS
                          ? CupertinoIcons.timer
                          : Icons.timelapse,
                      color: Colors.deepOrange,
                      onTap: _onSecurityItemClicked,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: SecurityItem(
                      securityIndex: 3,
                      number: _duplicatedEntries.length,
                      title: AppTranslations.of(context).text("duplicated"),
                      icon: Platform.isIOS
                          ? CupertinoIcons.arrow_2_circlepath_circle
                          : Icons.autorenew,
                      color: Colors.orange,
                      onTap: _onSecurityItemClicked,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: _displayLists(themeProvider)),
          ],
        ),
      ),
    );
  }

  Widget _displayLists(ThemeProvider themeProvider) {
    if (_weakPasswordEntries.isEmpty &&
        _oldEntries.isEmpty &&
        _duplicatedEntries.isEmpty &&
        !_isLoading) {
      return _securityImage();
    } else {
      return Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _displayListPasswords(
                  themeProvider,
                  AppTranslations.of(context).text("weak"),
                  _weakPasswordEntries,
                ),
                _displayListPasswords(
                  themeProvider,
                  AppTranslations.of(context).text("old"),
                  _oldEntries,
                ),
                _displayListPasswords(
                  themeProvider,
                  AppTranslations.of(context).text("duplicated"),
                  _duplicatedEntries,
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  Widget _securityImage() {
    return Container(
      margin: EdgeInsets.only(left: 16, right: 16),
      child: SvgPicture.asset(
        "assets/images/security_safe.svg",
        semanticsLabel: 'Safe',
        fit: BoxFit.fitWidth,
        height: 300,
      ),
    );
  }

  Widget _displayListPasswords(
    ThemeProvider themeProvider,
    String title,
    List<Entry> entries,
  ) {
    if (entries.isEmpty) {
      return SizedBox.shrink();
    } else {
      return Container(
        margin: EdgeInsets.only(top: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: themeProvider.textColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Column(
              children: _buildListItems(entries),
            ),
          ],
        ),
      );
    }
  }

  List<Widget> _buildListItems(List<Entry> entries) {
    List<Widget> items = [];

    for (var entry in entries) {
      items.add(
        EntryItem(
          entry: entry,
          isSelected: false,
          onTap: _onEntrySelected,
        ),
      );
    }

    return items;
  }

  _onEntrySelected(Entry entry) async {
    await ChicNavigator.push(
      context,
      EntryDetailScreen(
        entry: entry,
        previousPageTitle: AppTranslations.of(context).text("security"),
      ),
    );
    _checkPasswordSecurity();

    if (widget.onDataChanged != null) {
      widget.onDataChanged!();
    }
  }

  _onSecurityItemClicked(String title, int securityIndex) async {
    await ChicNavigator.push(context,
        SecurityEntryScreen(title: title, securityIndex: securityIndex));

    _checkPasswordSecurity();

    if (widget.onDataChanged != null) {
      widget.onDataChanged!();
    }
  }
}
