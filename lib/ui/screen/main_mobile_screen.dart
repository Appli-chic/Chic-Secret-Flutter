import 'package:chic_secret/localization/app_translations.dart';
import 'package:chic_secret/provider/theme_provider.dart';
import 'package:chic_secret/ui/component/clipper/half_circle_clipper.dart';
import 'package:chic_secret/ui/screen/category_screen.dart';
import 'package:chic_secret/ui/screen/passwords_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainMobileScreen extends StatefulWidget {
  @override
  _MainMobileScreenState createState() => _MainMobileScreenState();
}

class _MainMobileScreenState extends State<MainMobileScreen> {
  PageController _pageController = PageController();
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context, listen: true);

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      body: PageView(
        controller: _pageController,
        physics: NeverScrollableScrollPhysics(),
        children: [
          PasswordsScreen(),
          CategoriesScreen(),
          Container(),
          Container(),
          Container(),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: MediaQuery.of(context).viewInsets.bottom == 0
          ? _displaysFloatingButton(themeProvider)
          : null,
      bottomNavigationBar: _displayBottomBar(themeProvider),
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
            onPressed: () async {},
            child: Container(
              height: 56,
              width: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: themeProvider.primaryColor,
              ),
              child: Icon(Icons.add, size: 24),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}