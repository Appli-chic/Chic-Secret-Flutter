import 'package:chic_secret/component/common/chic_navigator.dart';
import 'package:chic_secret/model/database/user.dart';
import 'package:chic_secret/provider/synchronization_provider.dart';
import 'package:chic_secret/service/user_service.dart';
import 'package:chic_secret/feature/user/login/login_screen.dart';
import 'package:chic_secret/feature/vault/new/new_vault_screen.dart';
import 'package:chic_secret/utils/chic_platform.dart';
import 'package:chic_secret/utils/security.dart';
import 'package:chic_secret/utils/shared_data.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

class SettingsScreenViewModel with ChangeNotifier {
  final LocalAuthentication auth = LocalAuthentication();

  bool isBiometricsSupported = false;
  User? user = null;
  Function()? onDataChanged;

  SettingsScreenViewModel(Function()? onDataChanged) {
    this.onDataChanged = onDataChanged;
    checkBiometrics();
    getUser();
  }

  checkBiometrics() async {
    try {
      isBiometricsSupported = await auth.canCheckBiometrics;
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  getUser() async {
    user = await Security.getCurrentUser();
    if (user != null) {
      user = await UserService.getUserById(user!.id);
    }

    notifyListeners();
  }

  onEditVaultClicked(BuildContext context) async {
    var isDeleted = await ChicNavigator.push(
      context,
      NewVaultScreen(vault: selectedVault, isFromSettings: true),
      isModal: true,
    );

    if (onDataChanged != null) {
      onDataChanged!();
    }

    if (isDeleted != null && isDeleted) {
      if (!ChicPlatform.isDesktop()) {
        Navigator.pop(context, true);
      }
    }
  }

  synchronize(SynchronizationProvider synchronizationProvider) async {
    await synchronizationProvider.synchronize(isFullSynchronization: true);

    if (onDataChanged != null) {
      onDataChanged!();
    }
  }

  login(
    BuildContext context,
    SynchronizationProvider synchronizationProvider,
  ) async {
    var isLogged = await ChicNavigator.push(
      context,
      LoginScreen(),
      isModal: true,
    );

    if (isLogged) {
      getUser();
      await synchronizationProvider.synchronize(isFullSynchronization: true);

      if (onDataChanged != null) {
        onDataChanged!();
      }
    }
  }

  loggedOut() {
    user = null;
    notifyListeners();
  }
}
