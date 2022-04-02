import 'package:chic_secret/localization/app_translations.dart';
import 'package:chic_secret/model/database/entry.dart';
import 'package:chic_secret/provider/theme_provider.dart';
import 'package:chic_secret/ui/component/common/chic_navigator.dart';
import 'package:chic_secret/ui/component/security_item.dart';
import 'package:chic_secret/ui/screen/security_entry_screen.dart';
import 'package:chic_secret/utils/security.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(
        backgroundColor: themeProvider.secondBackgroundColor,
        title: Text(AppTranslations.of(context).text("security")),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Container(
          margin: EdgeInsets.only(top: 16, left: 16, right: 16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: SecurityItem(
                      securityIndex: 1,
                      number: _weakPasswordEntries.length,
                      title: AppTranslations.of(context).text("weak"),
                      icon: Icons.security,
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
                      icon: Icons.timelapse,
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
                      icon: Icons.autorenew,
                      color: Colors.orange,
                      onTap: _onSecurityItemClicked,
                    ),
                  ),
                ],
              ),
              Expanded(child: _securityImage()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _securityImage() {
    if (_weakPasswordEntries.isEmpty &&
        _oldEntries.isEmpty &&
        _duplicatedEntries.isEmpty &&
        !_isLoading) {
      return Container(
        margin: EdgeInsets.only(left: 16, right: 16),
        child: SvgPicture.asset(
          "assets/images/security_safe.svg",
          semanticsLabel: 'Safe',
          fit: BoxFit.fitWidth,
          height: 300,
        ),
      );
    } else {
      return SizedBox.shrink();
    }
  }

  _onSecurityItemClicked(String title, int securityIndex) async {
    await ChicNavigator.push(context,
        SecurityEntryScreen(title: title, securityIndex: securityIndex));

    _checkPasswordSecurity();
  }
}
