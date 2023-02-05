import 'package:chic_secret/model/database/category.dart';
import 'package:chic_secret/model/database/entry.dart';
import 'package:chic_secret/model/database/tag.dart';
import 'package:chic_secret/model/database/vault.dart';
import 'package:chic_secret/service/category_service.dart';
import 'package:chic_secret/service/tag_service.dart';
import 'package:chic_secret/service/vault_service.dart';
import 'package:chic_secret/utils/security.dart';
import 'package:chic_secret/utils/shared_data.dart';
import 'package:flutter/material.dart';

class SideBarViewModel with ChangeNotifier {
  late Function() onVaultChange;

  List<Vault> vaults = [];
  List<Category> categories = [];
  List<Tag> tags = [];

  List<Entry> weakPasswordEntries = [];
  List<Entry> oldEntries = [];
  List<Entry> duplicatedEntries = [];

  bool isUserLoggedIn = false;

  SideBarViewModel(Function() onVaultChange) {
    this.onVaultChange = onVaultChange;
    loadVaults();
    loadCategories();
    checkIsUserLoggedIn();
  }

  loadVaults() async {
    vaults = await VaultService.getAll();
    notifyListeners();
  }

  loadCategories() async {
    if (selectedVault != null) {
      categories = await CategoryService.getAllByVault(selectedVault!.id);

      checkPasswordSecurity();
      notifyListeners();
    }
  }

  loadTags() async {
    if (selectedVault != null) {
      tags = await TagService.getAllByVault(selectedVault!.id);
      notifyListeners();
    }
  }

  checkIsUserLoggedIn() async {
    isUserLoggedIn = await Security.isConnected();
    notifyListeners();
  }

  setUserLoggedIn() {
    isUserLoggedIn = true;
    notifyListeners();
  }

  checkPasswordSecurity() async {
    var data = await Security.retrievePasswordsSecurityInfo();

    weakPasswordEntries = data.item1;
    oldEntries = data.item2;
    duplicatedEntries = data.item3;

    notifyListeners();
  }

  onSynchronized() async {
    onVaultChange();
    loadVaults();
    loadCategories();
    loadTags();
    checkPasswordSecurity();
  }

  onAddVault(Vault vault, Function(Vault) goToUnlockVault) async {
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

    onSynchronized();
  }
}
