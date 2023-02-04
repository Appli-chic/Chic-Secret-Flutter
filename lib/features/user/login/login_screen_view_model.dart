import 'package:chic_secret/api/auth_api.dart';
import 'package:chic_secret/api/user_api.dart';
import 'package:chic_secret/localization/app_translations.dart';
import 'package:chic_secret/model/api_error.dart';
import 'package:chic_secret/service/user_service.dart';
import 'package:chic_secret/utils/constant.dart';
import 'package:chic_secret/utils/security.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class LoginScreenViewModel with ChangeNotifier {
  final formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final codeController = TextEditingController();

  bool isAskingCode = true;

  onAskingLoginCode(BuildContext context) async {
    if (checkEmailIsValid()) {
      EasyLoading.show();

      try {
        await AuthApi.askCodeToLogin(emailController.text.toLowerCase());
        EasyLoading.dismiss();

        isAskingCode = false;
        notifyListeners();
      } catch (e) {
        await EasyLoading.showError(
          AppTranslations.of(context).text("error_server"),
          duration: const Duration(milliseconds: 4000),
          dismissOnTap: true,
        );
      }
    } else {
      formKey.currentState!.validate();
    }
  }

  onLogin(BuildContext context) async {
    if (formKey.currentState != null && formKey.currentState!.validate()) {
      EasyLoading.show();

      try {
        await AuthApi.login(emailController.text.toLowerCase(), codeController.text,);
        var user = await UserApi.getCurrentUser();

        if (user != null) {
          if (await UserService.exists(user.id)) {
            await UserService.update(user);
          } else {
            await UserService.save(user);
          }

          await Security.setCurrentUser(user);
        }

        EasyLoading.dismiss();

        Navigator.pop(context, true);
      } catch (e) {
        if (e is ApiError) {
          if (e.code == codeErrorVerificationTokenInvalid) {
            await EasyLoading.showError(
              AppTranslations.of(context)
                  .text("error_verification_code_invalid"),
              duration: const Duration(milliseconds: 4000),
              dismissOnTap: true,
            );
          } else {
            await EasyLoading.showError(
              AppTranslations.of(context).text("error_server"),
              duration: const Duration(milliseconds: 4000),
              dismissOnTap: true,
            );
          }
        } else {
          await EasyLoading.showError(
            AppTranslations.of(context).text("error_server"),
            duration: const Duration(milliseconds: 4000),
            dismissOnTap: true,
          );
        }
      }
    }
  }

  bool checkEmailIsValid() {
    return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-z"
    r"A-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(emailController.text);
  }
}
