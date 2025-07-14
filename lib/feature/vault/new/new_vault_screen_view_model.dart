import 'package:chic_secret/api/user_api.dart';
import 'package:chic_secret/localization/app_translations.dart';
import 'package:chic_secret/model/database/category.dart';
import 'package:chic_secret/model/database/user.dart';
import 'package:chic_secret/model/database/vault.dart';
import 'package:chic_secret/model/database/vault_user.dart';
import 'package:chic_secret/provider/synchronization_provider.dart';
import 'package:chic_secret/service/category_service.dart';
import 'package:chic_secret/service/custom_field_service.dart';
import 'package:chic_secret/service/entry_service.dart';
import 'package:chic_secret/service/entry_tag_service.dart';
import 'package:chic_secret/service/tag_service.dart';
import 'package:chic_secret/service/user_service.dart';
import 'package:chic_secret/service/vault_service.dart';
import 'package:chic_secret/service/vault_user_service.dart';
import 'package:chic_secret/utils/constant.dart';
import 'package:chic_secret/utils/security.dart';
import 'package:chic_secret/utils/shared_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:uuid/uuid.dart';

class NewVaultScreenViewModel with ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  User? user;
  Vault? originalVault;

  var nameController = TextEditingController();
  final passwordController = TextEditingController();
  final verifyPasswordController = TextEditingController();
  final usersController = TextEditingController();

  List<String> emails = [];
  List<User> users = [];

  NewVaultScreenViewModel(Vault? vault) {
    this.originalVault = vault;

    if (vault != null) {
      nameController = TextEditingController(text: vault.name);
      _loadUsers(vault);
    }

    _getUser();
  }

  _loadUsers(Vault vault) async {
    users = await UserService.getUsersByVault(vault.id);

    for (var user in users) {
      emails.add(user.email);
    }
  }

  _getUser() async {
    user = await Security.getCurrentUser();
    if (user != null) {
      user = await UserService.getUserById(user!.id);
    }

    notifyListeners();
  }

  checkEmailExists(BuildContext context, String text) async {
    EasyLoading.show();

    try {
      var user = await UserApi.getUserByEmail(text);

      if (user != null && user.email == text) {
        await EasyLoading.showError(
          AppTranslations.of(context).text("error_user_cant_be_you"),
          duration: const Duration(milliseconds: 4000),
          dismissOnTap: true,
        );
      } else {
        if (user != null) {
          emails.add(text);
          usersController.clear();
          notifyListeners();
          EasyLoading.dismiss();

          if (await UserService.exists(user.id)) {
            UserService.update(user);
          } else {
            UserService.save(user);
          }
        } else {
          await EasyLoading.showError(
            AppTranslations.of(context).text("error_user_dont_exist"),
            duration: const Duration(milliseconds: 4000),
            dismissOnTap: true,
          );
        }
      }
    } catch (e) {
      print(e);

      await EasyLoading.showError(
        AppTranslations.of(context).text("error_user_dont_exist"),
        duration: const Duration(milliseconds: 4000),
        dismissOnTap: true,
      );
    }
  }

  delete(SynchronizationProvider synchronizationProvider) async {
    await VaultUserService.deleteFromVault(originalVault!.id);
    await EntryTagService.deleteAllFromVault(originalVault!.id);
    await TagService.deleteAllFromVault(originalVault!.id);
    await CustomFieldService.deleteAllFromVault(originalVault!.id);
    await CategoryService.deleteAllFromVault(originalVault!.id);
    await EntryService.deleteAllFromVault(originalVault!.id);
    await VaultService.delete(originalVault!);

    selectedVault = null;
    currentPassword = null;
    synchronizationProvider.synchronize();
  }

  save(BuildContext context,
      SynchronizationProvider synchronizationProvider) async {
    if (formKey.currentState != null && formKey.currentState!.validate()) {
      Vault vault;

      if (originalVault != null) {
        vault = await _updateVault();
      } else {
        vault = await _createNewVault(context);
      }

      await _saveAllUsers(vault);
      await _deleteUnusedTags(vault);

      synchronizationProvider.synchronize();

      Navigator.pop(context, vault);
    }
  }

  Future<Vault> _updateVault() async {
    final vault = originalVault!;
    vault.name = nameController.text;
    vault.updatedAt = DateTime.now();

    await VaultService.update(vault);

    return vault;
  }

  Future<Vault> _createNewVault(BuildContext context) async {
    final vault = Vault(
      id: Uuid().v4(),
      name: nameController.text,
      signature: Security.encrypt(passwordController.text, signature),
      userId: user != null ? user!.id : null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await VaultService.save(vault);
    await _createMandatoryCategories(context, vault);

    selectedVault = vault;
    currentPassword = passwordController.text;

    return vault;
  }

  _createMandatoryCategories(BuildContext context, Vault vault) async {
    var trashCategory = Category(
      id: Uuid().v4(),
      name: AppTranslations.of(context).text("trash"),
      color: "#fff44336",
      icon: 57785,
      isTrash: true,
      vaultId: vault.id,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    var generalCategory = Category(
      id: Uuid().v4(),
      name: AppTranslations.of(context).text("general"),
      color: "#ff2196f3",
      icon: 58136,
      isTrash: false,
      vaultId: vault.id,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await CategoryService.save(trashCategory);
    await CategoryService.save(generalCategory);
  }

  _saveAllUsers(Vault vault) async {
    for (var email in emails) {
      var user = await UserService.getUserByEmail(email);

      if (users.where((u) => u.email == user!.email).isEmpty) {
        var vaultUser = VaultUser(
          vaultId: vault.id,
          userId: user!.id,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await VaultUserService.save(vaultUser);
      }
    }
  }

  _deleteUnusedTags(Vault vault) async {
    for (var user in users) {
      if (emails.where((u) => u == user.email).isEmpty) {
        await VaultUserService.delete(vault.id, user.id);
      }
    }
  }
}
