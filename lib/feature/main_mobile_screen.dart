import 'dart:io';

import 'package:chic_secret/component/clipper/half_circle_clipper.dart';
import 'package:chic_secret/component/common/chic_navigator.dart';
import 'package:chic_secret/localization/app_translations.dart';
import 'package:chic_secret/provider/theme_provider.dart';
import 'package:chic_secret/feature/category/categories_screen.dart';
import 'package:chic_secret/feature/entry/entries_screen.dart';
import 'package:chic_secret/feature/entry/new/new_entry_screen.dart';
import 'package:chic_secret/feature/security/security_screen.dart';
import 'package:chic_secret/feature/settings/settings_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainMobileScreen extends StatefulWidget {
  @override
  _MainMobileScreenState createState() => _MainMobileScreenState();
}

class _MainMobileScreenState extends State<MainMobileScreen> {
  EntriesScreenController _passwordScreenController = EntriesScreenController();
  CategoriesScreenController _categoryScreenController =
      CategoriesScreenController();
  PageController _pageController = PageController();
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context, listen: true);
    return _displayScaffold(themeProvider);
  }

  Widget _displayScaffold(ThemeProvider themeProvider) {
    if (Platform.isIOS) {
      return CupertinoTabScaffold(
        backgroundColor: themeProvider.backgroundColor,
        tabBar: CupertinoTabBar(
          items: _displayBottomNavigationBarItems(),
        ),
        tabBuilder: (BuildContext context, int index) {
          if (index == 0) {
            return EntriesScreen(
              passwordScreenController: _passwordScreenController,
            );
          } else if (index == 1) {
            return CategoriesScreen(
              categoryScreenController: _categoryScreenController,
              onCategoriesChanged: () {
                if (_passwordScreenController.reloadPasswords != null) {
                  _passwordScreenController.reloadPasswords!();
                }
              },
            );
          } else if (index == 2) {
            return SecurityScreen(
              onDataChanged: () {
                if (_passwordScreenController.reloadPasswords != null) {
                  _passwordScreenController.reloadPasswords!();
                }
              },
            );
          } else if (index == 3) {
            return SettingsScreen(
              hasVaultLinked: true,
              onDataChanged: () {
                if (_passwordScreenController.reloadPasswords != null) {
                  _passwordScreenController.reloadPasswords!();
                }

                if (_categoryScreenController.reloadCategories != null) {
                  _categoryScreenController.reloadCategories!();
                }
              },
            );
          }

          return Container();
        },
      );
    } else {
      return Scaffold(
        backgroundColor: themeProvider.backgroundColor,
        body: _displayBody(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: MediaQuery.of(context).viewInsets.bottom == 0
            ? _displaysFloatingButton(themeProvider)
            : null,
        bottomNavigationBar: _displayBottomBar(themeProvider),
      );
    }
  }

  Widget _displayBody() {
    return PageView(
      controller: _pageController,
      physics: NeverScrollableScrollPhysics(),
      children: [
        EntriesScreen(
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
        SecurityScreen(
          onDataChanged: () {
            if (_passwordScreenController.reloadPasswords != null) {
              _passwordScreenController.reloadPasswords!();
            }
          },
        ),
        SettingsScreen(
          hasVaultLinked: true,
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
    );
  }

  _onTabClicked(int index) {
    if (_index != index) {
      setState(() {
        _index = index;
      });

      _pageController.jumpToPage(_index);
    }
  }

  NavigationBar _displayBottomBar(ThemeProvider themeProvider) {
    return NavigationBar(
      onDestinationSelected: _onTabClicked,
      indicatorColor: themeProvider.primaryColor,
      selectedIndex: _index,
      destinations: [
        NavigationDestination(
          icon: Icon(Icons.list_sharp),
          label: AppTranslations.of(context).text("passwords_bottom_bar"),
        ),
        NavigationDestination(
          icon: Icon(Icons.folder),
          label: AppTranslations.of(context).text("categories"),
        ),
        NavigationDestination(icon: const SizedBox(), label: ""),
        NavigationDestination(
          icon: Icon(Icons.security),
          label: AppTranslations.of(context).text("security"),
        ),
        NavigationDestination(
          icon: Icon(Icons.settings),
          label: AppTranslations.of(context).text("settings"),
        ),
      ],
    );
  }

  List<BottomNavigationBarItem> _displayBottomNavigationBarItems() {
    if(Platform.isIOS) {
      return [
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.list_dash),
          activeIcon: Icon(CupertinoIcons.list_dash),
          label: AppTranslations.of(context).text("passwords"),
        ),
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.folder_fill),
          activeIcon: Icon(CupertinoIcons.folder_fill),
          label: AppTranslations.of(context).text("categories"),
        ),
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.shield_lefthalf_fill),
          activeIcon: Icon(CupertinoIcons.shield_lefthalf_fill),
          label: AppTranslations.of(context).text("security"),
        ),
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.settings),
          activeIcon: Icon(CupertinoIcons.settings),
          label: AppTranslations.of(context).text("settings"),
        ),
      ];
    } else {
      return [
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
          icon: Icon(Icons.security),
          activeIcon: Icon(Icons.security),
          label: AppTranslations.of(context).text("security"),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          activeIcon: Icon(Icons.settings),
          label: AppTranslations.of(context).text("settings"),
        ),
      ];
    }
  }

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
      NewEntryScreen(previousPageTitle: ""),
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
