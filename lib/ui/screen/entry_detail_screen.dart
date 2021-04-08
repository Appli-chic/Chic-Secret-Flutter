import 'package:chic_secret/localization/app_translations.dart';
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
          ? _displaysBody(themeProvider)
          : _displaysBody(themeProvider),
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

  /// Displays the body of the screen
  Widget _displaysBody(ThemeProvider themeProvider) {
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
            ChicPlatform.isDesktop()
                ? EntryDetailInput(
                    label: AppTranslations.of(context).text("name"),
                    text: widget.entry.name,
                  )
                : SizedBox.shrink(),
            ChicPlatform.isDesktop() ? SizedBox(height: 24) : SizedBox.shrink(),
            EntryDetailInput(
              label: AppTranslations.of(context).text("username"),
              text: widget.entry.username,
              canCopy: true,
            ),
            SizedBox(height: 24),
            EntryDetailInput(
              label: AppTranslations.of(context).text("password"),
              text: Security.decrypt(currentPassword!, widget.entry.hash),
              canCopy: true,
              isPassword: true,
            ),
            SizedBox(height: 24),
            EntryDetailInput(
              label: AppTranslations.of(context).text("category"),
              text: widget.entry.category != null
                  ? widget.entry.category!.name
                  : "",
            ),
          ],
        ),
      ),
    );
  }
}
