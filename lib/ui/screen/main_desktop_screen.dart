import 'package:chic_secret/provider/theme_provider.dart';
import 'package:chic_secret/ui/component/common/split_view.dart';
import 'package:chic_secret/ui/screen/passwords_screen.dart';
import 'package:chic_secret/ui/screen/vaults_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainDesktopScreen extends StatefulWidget {
  @override
  _MainDesktopScreenState createState() => _MainDesktopScreenState();
}

class _MainDesktopScreenState extends State<MainDesktopScreen> {
  _reloadPasswordScreen() {}

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context, listen: true);

    return Scaffold(
      body: SplitView(
        gripColor: themeProvider.divider,
        view1: VaultsScreen(onVaultChange: _reloadPasswordScreen),
        view2: SplitView(
          gripColor: themeProvider.divider,
          view1: Center(child: PasswordsScreen()),
          view2: Center(
            child: Container(
              color: themeProvider.backgroundColor,
            ),
          ),
          initialWeight: 0.4,
          onWeightChanged: (double value) {},
        ),
        onWeightChanged: (double value) {},
      ),
    );
  }
}
