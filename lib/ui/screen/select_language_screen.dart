import 'package:chic_secret/localization/app_translations.dart';
import 'package:chic_secret/localization/application.dart';
import 'package:chic_secret/provider/theme_provider.dart';
import 'package:chic_secret/ui/component/common/chic_elevated_button.dart';
import 'package:chic_secret/ui/component/common/chic_text_button.dart';
import 'package:chic_secret/ui/component/common/desktop_modal.dart';
import 'package:chic_secret/utils/chic_platform.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SelectLanguageScreen extends StatefulWidget {
  final String? language;

  const SelectLanguageScreen({
    this.language,
  });

  @override
  _SelectLanguageScreenState createState() => _SelectLanguageScreenState();
}

class _SelectLanguageScreenState extends State<SelectLanguageScreen> {
  String _language = Application.supportedLanguages.first;

  @override
  void initState() {
    if (widget.language != null) {
      var index = Application.supportedLanguagesCodes.indexOf(widget.language!);

      if(index != -1) {
        _language = Application.supportedLanguages[index];
      }
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context, listen: true);

    if (ChicPlatform.isDesktop()) {
      return _displaysDesktopInModal(themeProvider);
    } else {
      return _displaysMobile(themeProvider);
    }
  }

  /// Displays the screen in a modal for the desktop version
  Widget _displaysDesktopInModal(ThemeProvider themeProvider) {
    return DesktopModal(
      title: AppTranslations.of(context).text("language"),
      body: _displaysBody(themeProvider),
      actions: [
        Container(
          margin: EdgeInsets.only(right: 8, bottom: 8),
          child: ChicTextButton(
            child: Text(AppTranslations.of(context).text("cancel")),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        Container(
          margin: EdgeInsets.only(right: 8, bottom: 8),
          child: ChicElevatedButton(
            child: Text(AppTranslations.of(context).text("done")),
            onPressed: () {
              var index = Application.supportedLanguages.indexOf(_language);
              Navigator.pop(context, Application.supportedLanguagesCodes[index]);
            },
          ),
        ),
      ],
    );
  }

  /// Displays the [Scaffold] for the mobile version
  Widget _displaysMobile(ThemeProvider themeProvider) {
    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(
        backgroundColor: themeProvider.secondBackgroundColor,
        title: Text(AppTranslations.of(context).text("language")),
        actions: [
          ChicTextButton(
            child: Text(AppTranslations.of(context).text("done")),
            onPressed: () {
              var index = Application.supportedLanguages.indexOf(_language);
              Navigator.pop(context, Application.supportedLanguagesCodes[index]);
            },
          ),
        ],
      ),
      body: _displaysBody(themeProvider),
    );
  }

  /// Displays a unified body for both mobile and desktop version
  Widget _displaysBody(ThemeProvider themeProvider) {
    return ListView.builder(
      physics: BouncingScrollPhysics(),
      shrinkWrap: true,
      itemCount: Application.supportedLanguages.length,
      itemBuilder: (context, index) {
        var isSelected = _language == Application.supportedLanguages[index];

        return ListTile(
          title: Text(
            Application.supportedLanguages[index],
            style: TextStyle(color: themeProvider.textColor),
          ),
          trailing: isSelected
              ? Icon(
                  Icons.check,
                  color: themeProvider.primaryColor,
                )
              : null,
          onTap: () {
            _language = Application.supportedLanguages[index];
            setState(() {});
          },
        );
      },
    );
  }
}
