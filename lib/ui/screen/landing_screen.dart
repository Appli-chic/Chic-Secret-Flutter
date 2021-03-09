import 'package:chic_secret/ui/screen/main_desktop_screen.dart';
import 'package:chic_secret/ui/screen/vaults_screen.dart';
import 'package:chic_secret/utils/chic_platform.dart';
import 'package:flutter/material.dart';

class LandingScreen extends StatefulWidget {
  @override
  _LandingScreenState createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  _firstConnection() async {
    if (ChicPlatform.isDesktop()) {
      return await Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainDesktopScreen()),
      );
    } else {
      return await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => VaultsScreen(
            onVaultChange: () {},
          ),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();

    Future(() {
      _firstConnection();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
