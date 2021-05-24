import 'package:chic_secret/provider/synchronization_provider.dart';
import 'package:chic_secret/ui/screen/main_desktop_screen.dart';
import 'package:chic_secret/ui/screen/vaults_screen.dart';
import 'package:chic_secret/utils/chic_platform.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LandingScreen extends StatefulWidget {
  @override
  _LandingScreenState createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  SynchronizationProvider? _synchronizationProvider;

  didChangeDependencies() {
    super.didChangeDependencies();

    if (_synchronizationProvider == null) {
      _synchronizationProvider =
          Provider.of<SynchronizationProvider>(context, listen: true);

      _firstSynchronization();
    }
  }

  /// Synchronize the first time we start the application
  _firstSynchronization() async {
    await _synchronizationProvider!.synchronize(isFullSynchronization: true);

    Future(() {
      _firstConnection();
    });
  }

  /// Displays the next screen depending if the application is launched on
  /// desktop or mobile version
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
  Widget build(BuildContext context) {
    return Container();
  }
}
