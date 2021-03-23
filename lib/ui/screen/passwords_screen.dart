import 'package:chic_secret/localization/app_translations.dart';
import 'package:chic_secret/model/database/category.dart';
import 'package:chic_secret/model/database/password.dart';
import 'package:chic_secret/provider/theme_provider.dart';
import 'package:chic_secret/ui/component/common/chic_icon_button.dart';
import 'package:chic_secret/ui/component/common/chic_navigator.dart';
import 'package:chic_secret/ui/component/common/chic_text_field.dart';
import 'package:chic_secret/ui/component/password_item.dart';
import 'package:chic_secret/ui/screen/new_password_screen.dart';
import 'package:chic_secret/utils/chic_platform.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class PasswordsScreen extends StatefulWidget {
  @override
  _PasswordsScreenState createState() => _PasswordsScreenState();
}

class _PasswordsScreenState extends State<PasswordsScreen> {
  List<Password> _passwords = [
    Password(
      id: Uuid().v4(),
      name: "Gmail",
      username: "applichic@gmail.com",
      hash: "",
      vaultId: Uuid().v4(),
      categoryId: Uuid().v4(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      category: Category(
        id: Uuid().v4(),
        name: "Email",
        color: '#${Colors.red.value.toRadixString(16)}',
        icon: Icons.email.codePoint,
        vaultId: Uuid().v4(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ),
    Password(
      id: Uuid().v4(),
      name: "Protonmail",
      username: "gbelouin@protonmail.com",
      hash: "",
      vaultId: Uuid().v4(),
      categoryId: Uuid().v4(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      category: Category(
        id: Uuid().v4(),
        name: "Email",
        color: '#${Colors.red.value.toRadixString(16)}',
        icon: Icons.email.codePoint,
        vaultId: Uuid().v4(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ),
    Password(
      id: Uuid().v4(),
      name: "Spotify",
      username: "applichic@gmail.com",
      hash: "",
      vaultId: Uuid().v4(),
      categoryId: Uuid().v4(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      category: Category(
        id: Uuid().v4(),
        name: "Music",
        color: '#${Colors.green.value.toRadixString(16)}',
        icon: Icons.music_note.codePoint,
        vaultId: Uuid().v4(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ),
  ];

  final _searchController = TextEditingController();
  var _searchFocusNode = FocusNode();
  var _desktopSearchFocusNode = FocusNode();

  Password? _selectedPassword;

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
                  onPressed: _onAddPasswordClicked,
                  icon: Icons.add,
                  type: ChicIconButtonType.filledRectangle,
                ),
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _passwords.length,
              itemBuilder: (context, index) {
                return PasswordItem(
                  password: _passwords[index],
                  isSelected: _selectedPassword != null &&
                      _selectedPassword == _passwords[index],
                  onTap: (Password password) {
                    setState(() {
                      _selectedPassword = password;
                    });
                  },
                );
              },
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      itemCount: _passwords.length,
      itemBuilder: (context, index) {
        return PasswordItem(
          password: _passwords[index],
          isSelected: false,
          onTap: (Password password) {},
        );
      },
    );
  }

  _onAddPasswordClicked() async {
    var data =
        await ChicNavigator.push(context, NewPasswordScreen(), isModal: true);

    if (data != null) {}
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _desktopSearchFocusNode.dispose();

    super.dispose();
  }
}
