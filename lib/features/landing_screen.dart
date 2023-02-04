import 'dart:async';

import 'package:chic_secret/provider/synchronization_provider.dart';
import 'package:chic_secret/features/main_desktop_screen.dart';
import 'package:chic_secret/features/vault/vaults_screen.dart';
import 'package:chic_secret/utils/chic_platform.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LandingScreen extends StatefulWidget {
  @override
  _LandingScreenState createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  VaultScreenController _vaultScreenController = VaultScreenController();
  MainDesktopScreenController _mainDesktopScreenController =
      MainDesktopScreenController();
  SynchronizationProvider? _synchronizationProvider;

  didChangeDependencies() {
    super.didChangeDependencies();

    if (_synchronizationProvider == null) {
      _synchronizationProvider =
          Provider.of<SynchronizationProvider>(context, listen: true);

      _firstSynchronization();
    }
  }

  _firstSynchronization() async {
    Future(() {
      _firstConnection();
    });

    await _synchronizationProvider!.synchronize(isFullSynchronization: true);

    if (_mainDesktopScreenController.reloadAfterSynchronization != null) {
      _mainDesktopScreenController.reloadAfterSynchronization!();
    }

    if (_vaultScreenController.reloadVaults != null) {
      _vaultScreenController.reloadVaults!();
    }
  }

  _firstConnection() async {
    if (ChicPlatform.isDesktop()) {
      return await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainDesktopScreen(
            mainDesktopScreenController: _mainDesktopScreenController,
          ),
        ),
      );
    } else {
      return await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => VaultsScreen(
            vaultScreenController: _vaultScreenController,
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
