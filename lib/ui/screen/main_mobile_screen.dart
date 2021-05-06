import 'package:chic_secret/localization/app_translations.dart';
import 'package:chic_secret/provider/theme_provider.dart';
import 'package:chic_secret/ui/component/clipper/half_circle_clipper.dart';
import 'package:chic_secret/ui/component/common/chic_navigator.dart';
import 'package:chic_secret/ui/component/common/chic_text_button.dart';
import 'package:chic_secret/ui/screen/category_screen.dart';
import 'package:chic_secret/ui/screen/entry_screen.dart';
import 'package:chic_secret/ui/screen/new_entry_screen.dart';
import 'package:chic_secret/ui/screen/security_screen.dart';
import 'package:chic_secret/ui/screen/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainMobileScreen extends StatefulWidget {
  @override
  _MainMobileScreenState createState() => _MainMobileScreenState();
}

class _MainMobileScreenState extends State<MainMobileScreen> {
  EntryScreenController _passwordScreenController = EntryScreenController();
  CategoryScreenController _categoryScreenController =
      CategoryScreenController();
  PageController _pageController = PageController();
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context, listen: true);

    return WillPopScope(
      onWillPop: () async {
        var willPop = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: themeProvider.secondBackgroundColor,
              title: Text(AppTranslations.of(context).text("warning")),
              content: Text(
                  AppTranslations.of(context).text("message_will_lock_vault")),
              actions: [
                ChicTextButton(
                  child: Text(AppTranslations.of(context).text("no")),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                ChicTextButton(
                  child: Text(AppTranslations.of(context).text("yes")),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            );
          },
        );

        return willPop;
      },
      child: Scaffold(
        backgroundColor: themeProvider.backgroundColor,
        body: PageView(
          controller: _pageController,
          physics: NeverScrollableScrollPhysics(),
          children: [
            EntryScreen(
              passwordScreenController: _passwordScreenController,
            ),
            CategoriesScreen(
              categoryScreenController: _categoryScreenController,
              onCategoriesChanged: () {
                if (_passwordScreenController.reloadPasswords != null) {
                  _passwordScreenController.reloadPasswords!();
                }
              },
            ),
            Container(),
            SecurityScreen(),
            SettingsScreen(
              onDataChanged: () {
                if (_passwordScreenController.reloadPasswords != null) {
                  _passwordScreenController.reloadPasswords!();
                }

                if (_categoryScreenController.reloadCategories != null) {
                  _categoryScreenController.reloadCategories!();
                }
              },
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: MediaQuery.of(context).viewInsets.bottom == 0
            ? _displaysFloatingButton(themeProvider)
            : null,
        bottomNavigationBar: _displayBottomBar(themeProvider),
      ),
    );
  }

  /// Changes the displayed tab to the specified [index]
  _onTabClicked(int index) {
    if (_index != index) {
      setState(() {
        _index = index;
      });

      _pageController.jumpToPage(_index);
    }
  }

  /// Displays the bottom navigation bar in the mobile version
  BottomNavigationBar _displayBottomBar(ThemeProvider themeProvider) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: themeProvider.secondBackgroundColor,
      elevation: 0,
      currentIndex: _index,
      onTap: _onTabClicked,
      selectedItemColor: themeProvider.primaryColor,
      selectedLabelStyle: TextStyle(
        color: themeProvider.primaryColor,
      ),
      unselectedItemColor: themeProvider.placeholder,
      unselectedLabelStyle: TextStyle(
        color: themeProvider.placeholder,
      ),
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.list_sharp),
          activeIcon: Icon(Icons.list_sharp),
          label: AppTranslations.of(context).text("passwords"),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.folder),
          activeIcon: Icon(Icons.folder),
          label: AppTranslations.of(context).text("categories"),
        ),
        BottomNavigationBarItem(icon: const SizedBox(), label: ""),
        BottomNavigationBarItem(
          icon: Icon(Icons.shield),
          activeIcon: Icon(Icons.shield),
          label: AppTranslations.of(context).text("security"),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          activeIcon: Icon(Icons.settings),
          label: AppTranslations.of(context).text("settings"),
        ),
      ],
    );
  }

  /// Displays a centered floating button to create a new password
  Widget _displaysFloatingButton(ThemeProvider themeProvider) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        ClipPath(
          clipper: HalfCircleClipper(),
          child: Container(
            height: 75,
            width: 75,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: themeProvider.backgroundColor,
            ),
          ),
        ),
        SizedBox(
          height: 56,
          width: 56,
          child: FloatingActionButton(
            backgroundColor: Colors.transparent,
            elevation: 0,
            highlightElevation: 0,
            onPressed: _onAddEntryClicked,
            child: Container(
              height: 56,
              width: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: themeProvider.primaryColor,
              ),
              child: Icon(
                Icons.add,
                size: 24,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Call the [NewEntryScreen] screen to create a new entry.
  _onAddEntryClicked() async {
    var data = await ChicNavigator.push(
      context,
      NewEntryScreen(),
      isModal: true,
    );

    if (_categoryScreenController.reloadCategories != null) {
      _categoryScreenController.reloadCategories!();
    }

    if (data != null) {
      if (_passwordScreenController.reloadPasswords != null) {
        _passwordScreenController.reloadPasswords!();
      }

      setState(() {});
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
