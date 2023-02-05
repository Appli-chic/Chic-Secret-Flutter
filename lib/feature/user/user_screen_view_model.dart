import 'package:chic_secret/api/user_api.dart';
import 'package:chic_secret/model/database/user.dart';
import 'package:chic_secret/service/user_service.dart';
import 'package:chic_secret/utils/security.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class UserScreenViewModel with ChangeNotifier {
  User? user;

  UserScreenViewModel() {
    getUser();
  }

  getUser() async {
    user = await Security.getCurrentUser();
    if (user != null) {
      user = await UserService.getUserById(user!.id);
    }

    notifyListeners();
  }


  logout(BuildContext context) async {
    await Security.logout();
    Navigator.of(context).pop(true);
  }

  deleteAccount(BuildContext context) async {
    try {
      EasyLoading.show();
      await UserApi.deleteUser();
    } catch (e) {}

    EasyLoading.dismiss();

    logout(context);
  }
}
