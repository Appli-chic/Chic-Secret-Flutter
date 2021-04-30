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

  /// Synchronize all the elements of the user in the local database
  Future<void> synchronize() async {
    if (!_isSynchronizing) {
      _isSynchronizing = true;
      notifyListeners();

      await Future.delayed(Duration(seconds: 3));
      await setLastSyncDate();

      _isSynchronizing = false;
      notifyListeners();
    }
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
