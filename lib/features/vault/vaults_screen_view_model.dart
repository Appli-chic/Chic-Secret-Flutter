import 'package:chic_secret/model/database/vault.dart';
import 'package:chic_secret/service/vault_service.dart';
import 'package:chic_secret/utils/security.dart';
import 'package:chic_secret/utils/shared_data.dart';
import 'package:flutter/material.dart';

class VaultsScreenViewModel with ChangeNotifier {
  List<Vault> vaults = [];
  bool isUserLoggedIn = false;

  VaultsScreenViewModel() {
    loadVaults();
  }

  loadVaults() async {
    vaults = await VaultService.getAll();
    notifyListeners();
  }

  checkIsUserLoggedIn() async {
    isUserLoggedIn = await Security.isConnected();
    notifyListeners();
  }

  setUserLoggedIn() {
    isUserLoggedIn = true;
    notifyListeners();
  }

  onAddVaultDesktop(Vault vault, Function(Vault) goToUnlockVault) async {
    var unlockingPassword;

    if (vaultPasswordMap[vault.id] != null) {
      unlockingPassword = vaultPasswordMap[vault.id];
    } else {
      unlockingPassword = await goToUnlockVault(vault);
      if (unlockingPassword == null) {
        return;
      }

      vaultPasswordMap[vault.id] = unlockingPassword;
    }

    selectedCategory = null;
    selectedVault = vault;
    currentPassword = unlockingPassword;

    loadVaults();
  }
}
