import 'package:chic_secret/model/database/entry.dart';
import 'package:chic_secret/utils/security.dart';
import 'package:flutter/material.dart';

class SecurityScreenViewModel with ChangeNotifier {
  List<Entry> weakPasswordEntries = [];
  List<Entry> oldEntries = [];
  List<Entry> duplicatedEntries = [];
  bool isLoading = true;

  SecurityScreenViewModel() {
    checkPasswordSecurity();
  }

  checkPasswordSecurity() async {
    var data = await Security.retrievePasswordsSecurityInfo();

    weakPasswordEntries = data.item1;
    oldEntries = data.item2;
    duplicatedEntries = data.item3;
    isLoading = false;

    notifyListeners();
  }
}
