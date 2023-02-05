import 'package:chic_secret/model/database/entry.dart';
import 'package:chic_secret/utils/security.dart';
import 'package:flutter/material.dart';

class SecurityEntriesScreenViewModel with ChangeNotifier {
  List<Entry> entries = [];
  late int securityIndex;

  SecurityEntriesScreenViewModel(int securityIndex) {
    this.securityIndex = securityIndex;
    checkPasswordSecurity();
  }

  checkPasswordSecurity() async {
    var data = await Security.retrievePasswordsSecurityInfo();

    switch (securityIndex) {
      case 1:
        entries = data.item1;
        break;
      case 2:
        entries = data.item2;
        break;
      case 3:
        entries = data.item3;
        break;
      default:
        entries = data.item1;
        break;
    }

    notifyListeners();
  }
}
