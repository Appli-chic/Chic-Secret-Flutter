import 'package:chic_secret/localization/app_translations.dart';
import 'package:chic_secret/model/database/entry.dart';
import 'package:chic_secret/provider/theme_provider.dart';
import 'package:chic_secret/ui/component/common/chic_navigator.dart';
import 'package:chic_secret/ui/component/security_item.dart';
import 'package:chic_secret/ui/screen/security_entry_screen.dart';
import 'package:chic_secret/utils/security.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen();

  @override
  _SecurityScreenState createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  List<Entry> _weakPasswordEntries = [];
  List<Entry> _oldEntries = [];
  List<Entry> _duplicatedEntries = [];

  @override
  void initState() {
    _checkPasswordSecurity();
    super.initState();
  }

  /// Check the security of all the entries
  _checkPasswordSecurity() async {
    var data = await Security.retrievePasswordsSecurityInfo();

    _weakPasswordEntries = data.item1;
    _oldEntries = data.item2;
    _duplicatedEntries = data.item3;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context, listen: true);

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(
        backgroundColor: themeProvider.secondBackgroundColor,
        brightness: themeProvider.getBrightness(),
        title: Text(AppTranslations.of(context).text("security")),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Container(
          margin: EdgeInsets.only(top: 8),
          child: Column(
            children: [
              SecurityItem(
                securityIndex: 1,
                number: _weakPasswordEntries.length,
                title: AppTranslations.of(context).text("weak_passwords"),
                color: Colors.red,
                onTap: _onSecurityItemClicked,
              ),
              SecurityItem(
                securityIndex: 2,
                number: _oldEntries.length,
                title: AppTranslations.of(context).text("old_passwords"),
                color: Colors.deepOrange,
                onTap: _onSecurityItemClicked,
              ),
              SecurityItem(
                securityIndex: 3,
                number: _duplicatedEntries.length,
                title: AppTranslations.of(context).text("duplicated_passwords"),
                color: Colors.orange,
                onTap: _onSecurityItemClicked,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Displays the list of elements to change for security purposes
  _onSecurityItemClicked(String title, int securityIndex) async {
    await ChicNavigator.push(context,
        SecurityEntryScreen(title: title, securityIndex: securityIndex));

    _checkPasswordSecurity();
  }
}
