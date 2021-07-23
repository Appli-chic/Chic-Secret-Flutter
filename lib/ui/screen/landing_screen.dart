import 'dart:async';

import 'package:chic_secret/provider/synchronization_provider.dart';
import 'package:chic_secret/service/user_service.dart';
import 'package:chic_secret/ui/screen/main_desktop_screen.dart';
import 'package:chic_secret/ui/screen/subscribe_screen.dart';
import 'package:chic_secret/ui/screen/vaults_screen.dart';
import 'package:chic_secret/utils/chic_platform.dart';
import 'package:chic_secret/utils/security.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
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

  /// Synchronize the first time we start the application
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

    if (_vaultScreenController.reloadCategories != null) {
      _vaultScreenController.reloadCategories!();
    }

    if (_vaultScreenController.reloadTags != null) {
      _vaultScreenController.reloadTags!();
    }
  }

  /// Displays the next screen depending if the application is launched on
  /// desktop or mobile version
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
