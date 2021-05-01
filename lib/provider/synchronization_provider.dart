import 'package:chic_secret/api/category_api.dart';
import 'package:chic_secret/api/entry_api.dart';
import 'package:chic_secret/api/vault_api.dart';
import 'package:chic_secret/service/category_service.dart';
import 'package:chic_secret/service/entry_service.dart';
import 'package:chic_secret/service/vault_service.dart';
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

  /// Synchronize all the elements of the user in the local database and to the server
  Future<void> synchronize() async {
    if (!_isSynchronizing) {
      _isSynchronizing = true;
      notifyListeners();

      try {
        await _push();
        await _pull();
        await setLastSyncDate();
      } catch (e) {
        print(e);
      }

      _isSynchronizing = false;
      notifyListeners();
    }
  }

  /// Push the data to the server
  Future<void> _push() async {
    var user = await Security.getCurrentUser();

    // Retrieve data to synchronize from the local database
    var vaults = await VaultService.getVaultsToSynchronize(_lastSyncDate);
    var categories =
        await CategoryService.getCategoriesToSynchronize(_lastSyncDate);
    var entries = await EntryService.getEntriesToSynchronize(_lastSyncDate);

    // Check if vaults have a user ID before to synchronize
    for (var vault in vaults) {
      if (vault.userId == null || vault.userId!.isEmpty) {
        vault.userId = user!.id;
        await VaultService.update(vault);
      }
    }

    // Send the data to the server
    if (vaults.isNotEmpty) {
      await VaultApi.sendVaults(vaults);
    }

    if (categories.isNotEmpty) {
      await CategoryApi.sendCategories(categories);
    }

    if (entries.isNotEmpty) {
      await EntryApi.sendEntries(entries);
    }
  }

  /// Get all the data that changed from the server
  Future<void> _pull() async {
    await VaultApi.retrieveVaults(_lastSyncDate);
    await CategoryApi.retrieveCategories(_lastSyncDate);
    await EntryApi.retrieveEntries(_lastSyncDate);
  }

  /// Get the last date of synchronization
  Future<void> _getLastSyncDate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var dateString = prefs.getString(lastDateSyncKey);

    if (dateString != null && dateString.isNotEmpty) {
      _lastSyncDate = DateTime.parse(dateString);
      notifyListeners();
    }
  }

  /// Set the last date of synchronization
  Future<void> setLastSyncDate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var today = DateTime.now();
    var dateFormatter = DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'");
    String todayString = dateFormatter.format(today);

    await prefs.setString(lastDateSyncKey, todayString);
    _getLastSyncDate();
  }

  /// Get the last sync date
  DateTime? get lastSyncDate => _lastSyncDate;

  /// Is it synchronizing
  bool get isSynchronizing => _isSynchronizing;
}
