import 'package:chic_secret/api/category_api.dart';
import 'package:chic_secret/api/custom_field_api.dart';
import 'package:chic_secret/api/entry_api.dart';
import 'package:chic_secret/api/entry_tag_api.dart';
import 'package:chic_secret/api/tag_api.dart';
import 'package:chic_secret/api/user_api.dart';
import 'package:chic_secret/api/vault_api.dart';
import 'package:chic_secret/api/vault_user_api.dart';
import 'package:chic_secret/service/category_service.dart';
import 'package:chic_secret/service/custom_field_service.dart';
import 'package:chic_secret/service/entry_service.dart';
import 'package:chic_secret/service/entry_tag_service.dart';
import 'package:chic_secret/service/tag_service.dart';
import 'package:chic_secret/service/user_service.dart';
import 'package:chic_secret/service/vault_service.dart';
import 'package:chic_secret/service/vault_user_service.dart';
import 'package:chic_secret/utils/security.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

const String lastDateSyncKey = "lastDateSyncKey";

class SynchronizationProvider with ChangeNotifier {
  bool _isSynchronizing = false;
  DateTime? _lastSyncDate;

  SynchronizationProvider() {
    _getLastSyncDate();
  }

  Future<void> synchronize({bool isFullSynchronization = false}) async {
    if (!_isSynchronizing) {
      if (await Security.isConnected()) {
        _isSynchronizing = true;
        notifyListeners();

        if (isFullSynchronization) {
          _lastSyncDate = null;
        }

        try {
          var synchronizationDate = DateTime.now();
          await _push();
          await _pull();
          await setLastSyncDate(dateToSet: synchronizationDate);
        } catch (e) {
          print(e);
        }

        _isSynchronizing = false;
        notifyListeners();
      }
    }
  }

  Future<void> _push() async {
    var user = await Security.getCurrentUser();

    var vaults = await VaultService.getVaultsToSynchronize(_lastSyncDate);
    var categories =
        await CategoryService.getCategoriesToSynchronize(_lastSyncDate);
    var entries = await EntryService.getEntriesToSynchronize(_lastSyncDate);
    var customFields =
        await CustomFieldService.getCustomFieldsToSynchronize(_lastSyncDate);
    var tags = await TagService.getTagsToSynchronize(_lastSyncDate);
    var entryTags =
        await EntryTagService.getEntryTagsToSynchronize(_lastSyncDate);
    var vaultUsers =
        await VaultUserService.getVaultUsersToSynchronize(_lastSyncDate);

    for (var vault in vaults) {
      if (vault.userId == null || vault.userId!.isEmpty) {
        vault.userId = user!.id;
        await VaultService.update(vault);
      }
    }

    if (user != null) {
      user = await UserService.getUserById(user.id);

      if (user != null) {
        await UserApi.sendUser(user);
      }
    }

    if (vaults.isNotEmpty) {
      await VaultApi.sendVaults(vaults);
    }

    if (categories.isNotEmpty) {
      await CategoryApi.sendCategories(categories);
    }

    if (entries.isNotEmpty) {
      await EntryApi.sendEntries(entries);
    }

    if (customFields.isNotEmpty) {
      await CustomFieldApi.sendCustomFields(customFields);
    }

    if (tags.isNotEmpty) {
      await TagApi.sendTags(tags);
    }

    if (entryTags.isNotEmpty) {
      await EntryTagApi.sendEntryTags(entryTags);
    }

    if (vaultUsers.isNotEmpty) {
      await VaultUserApi.sendVaultUsers(vaultUsers);
    }
  }

  Future<void> _pull() async {
    var user = await Security.getCurrentUser();
    if (user != null) {
      user = await UserService.getUserById(user.id);

      if (user != null) {
        var newUser = await UserApi.getCurrentUser();

        if (newUser != null &&
            newUser.updatedAt.millisecond > user.updatedAt.millisecond) {
          await UserService.update(newUser);
          await Security.setCurrentUser(user);
        }
      }
    }

    await UserApi.retrieveUsers(_lastSyncDate);
    await VaultApi.retrieveVaults(_lastSyncDate);
    await CategoryApi.retrieveCategories(_lastSyncDate);
    await EntryApi.retrieveEntries(_lastSyncDate);
    await CustomFieldApi.retrieveCustomFields(_lastSyncDate);
    await TagApi.retrieveTags(_lastSyncDate);
    await EntryTagApi.retrieveEntryTags(_lastSyncDate);
    await VaultUserApi.retrieveVaultUsers(_lastSyncDate);
  }

  Future<void> _getLastSyncDate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var dateString = prefs.getString(lastDateSyncKey);

    if (dateString != null && dateString.isNotEmpty) {
      _lastSyncDate = DateTime.parse(dateString);
      notifyListeners();
    }
  }

  Future<void> setLastSyncDate({DateTime? dateToSet}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var date = DateTime.now();

    if (dateToSet != null) {
      date = dateToSet;
    }

    var dateFormatter = DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'");
    String todayString = dateFormatter.format(date);

    await prefs.setString(lastDateSyncKey, todayString);
    _getLastSyncDate();
  }

  DateTime? get lastSyncDate => _lastSyncDate;

  bool get isSynchronizing => _isSynchronizing;
}
