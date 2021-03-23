import 'package:chic_secret/localization/app_translations.dart';
import 'package:chic_secret/provider/theme_provider.dart';
import 'package:chic_secret/ui/component/common/chic_icon_button.dart';
import 'package:chic_secret/ui/component/common/chic_text_field.dart';
import 'package:chic_secret/utils/chic_platform.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PasswordsScreen extends StatefulWidget {
  @override
  _PasswordsScreenState createState() => _PasswordsScreenState();
}

class _PasswordsScreenState extends State<PasswordsScreen> {
  final _searchController = TextEditingController();
  var _searchFocusNode = FocusNode();
  var _desktopSearchFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context, listen: true);

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: _displaysAppbar(themeProvider),
      body: _displayBody(themeProvider),
    );
  }

  PreferredSizeWidget? _displaysAppbar(ThemeProvider themeProvider) {
    if (!ChicPlatform.isDesktop()) {
      return AppBar(
        backgroundColor: themeProvider.secondBackgroundColor,
        brightness: themeProvider.getBrightness(),
        title: Text(AppTranslations.of(context).text("passwords")),
        actions: [
          IconButton(
            icon: Icon(
              Icons.add,
              color: themeProvider.textColor,
            ),
            onPressed: _onAddPasswordClicked,
          )
        ],
      );
    } else {
      return null;
    }
  }

  Widget _displayBody(ThemeProvider themeProvider) {
    if (ChicPlatform.isDesktop()) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 16, top: 16),
                  child: ChicTextField(
                    controller: _searchController,
                    hint: AppTranslations.of(context).text("search_passwords"),
                    desktopFocus: _desktopSearchFocusNode,
                    focus: _searchFocusNode,
                    type: ChicTextFieldType.filledRounded,
                    prefix: Container(
                      margin: EdgeInsets.only(left: 8, right: 8),
                      child: Icon(
                        Icons.search,
                        color: themeProvider.placeholder,
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 16, right: 16, top: 16),
                child: ChicIconButton(
                  onPressed: () {},
                  icon: Icons.add,
                  type: ChicIconButtonType.filledRectangle,
                ),
              ),
            ],
          ),
        ],
      );
    }

    return Column(
      children: [],
    );
  }

  _onAddPasswordClicked() async {}

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _desktopSearchFocusNode.dispose();

    super.dispose();
  }
}
