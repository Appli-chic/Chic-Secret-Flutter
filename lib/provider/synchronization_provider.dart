import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

const String lastDateSyncKey = "lastDateSyncKey";

class SynchronizationProvider with ChangeNotifier {
  DateTime? _lastSyncDate;

  SynchronizationProvider() {
    _getLastSyncDate();
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
}
