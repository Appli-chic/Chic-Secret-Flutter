import 'package:chic_secret/features/vault/vaults_screen.dart';
import 'package:chic_secret/model/database/category.dart';
import 'package:chic_secret/model/database/entry.dart';
import 'package:chic_secret/model/database/tag.dart';
import 'package:chic_secret/model/database/vault.dart';
import 'package:chic_secret/service/category_service.dart';
import 'package:chic_secret/service/entry_service.dart';
import 'package:chic_secret/service/tag_service.dart';
import 'package:chic_secret/service/vault_service.dart';
import 'package:chic_secret/utils/chic_platform.dart';
import 'package:chic_secret/utils/security.dart';
import 'package:flutter/material.dart';

class VaultsScreenViewModel with ChangeNotifier {
  late Function() onVaultChange;

  List<Vault> vaults = [];
  List<Category> categories = [];
  List<Tag> tags = [];

  List<Entry> weakPasswordEntries = [];
  List<Entry> oldEntries = [];
  List<Entry> duplicatedEntries = [];

  bool isUserLoggedIn = false;

  VaultsScreenViewModel(Function() onVaultChange) {
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

      if (ChicPlatform.isDesktop()) {
        checkPasswordSecurity();
      }

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

    if (ChicPlatform.isDesktop()) {
      loadVaults();
      loadCategories();
      loadTags();
      checkPasswordSecurity();
    }
  }

  onAddVaultDesktop(Vault vault, Function(Vault) goToUnlockVault) async {
    var unlockingPassword;

    if (vaultPasswordMap[vault.id] != null) {
      // The vault is already unlocked
      unlockingPassword = vaultPasswordMap[vault.id];
    } else {
      // The vault need to be unlocked
      unlockingPassword = await goToUnlockVault(vault);

      // If the vault haven't been unlocked then we stop it there
      if (unlockingPassword == null) {
        return;
      }

      // We just unlocked the vault so we save this information
      vaultPasswordMap[vault.id] = unlockingPassword;
    }

    // Set the selected category back to null
    selectedCategory = null;
    selectedVault = vault;
    currentPassword = unlockingPassword;

    // Set the entry length if they don't have one
    var entriesWithoutPasswordLength =
    await EntryService.getEntriesWithoutPasswordLength();

    Future(() async {
      for (var entry in entriesWithoutPasswordLength) {
        try {
          var password = Security.decrypt(currentPassword!, entry.hash);

          entry.passwordSize = password.length;
          entry.updatedAt = DateTime.now();
          await EntryService.update(entry);
        } catch (e) {
          print(e);
        }
      }

      checkPasswordSecurity();
    });

    onSynchronized();
  }
}
