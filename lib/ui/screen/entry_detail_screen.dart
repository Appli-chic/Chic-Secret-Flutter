import 'package:chic_secret/model/database/entry.dart';
import 'package:chic_secret/provider/theme_provider.dart';
import 'package:chic_secret/ui/component/entry_detail_input.dart';
import 'package:chic_secret/ui/screen/vaults_screen.dart';
import 'package:chic_secret/utils/chic_platform.dart';
import 'package:chic_secret/utils/security.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EntryDetailScreen extends StatefulWidget {
  final Entry entry;

  EntryDetailScreen({
    required this.entry,
  });

  @override
  _EntryDetailScreenState createState() => _EntryDetailScreenState();
}

class _EntryDetailScreenState extends State<EntryDetailScreen> {
  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context, listen: true);

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: _displaysAppbar(themeProvider),
      body: ChicPlatform.isDesktop()
          ? _displaysDesktopBody(themeProvider)
          : _displaysMobileBody(themeProvider),
    );
  }

  /// Displays the appbar that is only appearing on the mobile version
  PreferredSizeWidget? _displaysAppbar(ThemeProvider themeProvider) {
    if (!ChicPlatform.isDesktop()) {
      return AppBar(
        backgroundColor: themeProvider.secondBackgroundColor,
        brightness: themeProvider.getBrightness(),
        title: Text(widget.entry.name),
        actions: [],
      );
    } else {
      return null;
    }
  }

  /// Displays the body of the screen for the Desktop version
  Widget _displaysDesktopBody(ThemeProvider themeProvider) {
    return Container(
      margin: EdgeInsets.all(20),
      child: Container(
        width: double.maxFinite,
        decoration: BoxDecoration(
          color: themeProvider.secondBackgroundColor,
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            EntryDetailInput(
              label: "Name",
              text: widget.entry.name,
            ),
            SizedBox(height: 24),
            EntryDetailInput(
              label: "Username",
              text: widget.entry.username,
              canCopy: true,
            ),
            SizedBox(height: 24),
            EntryDetailInput(
              label: "Password",
              text: Security.decrypt(currentPassword!, widget.entry.hash),
              canCopy: true,
              isPassword: true,
            ),
          ],
        ),
      ),
    );
  }

  /// Displays the body of the screen for the Mobile version
  Widget _displaysMobileBody(ThemeProvider themeProvider) {
    return Container();
  }
}
