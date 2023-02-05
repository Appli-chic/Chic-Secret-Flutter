import 'package:chic_secret/localization/app_translations.dart';
import 'package:chic_secret/model/database/vault.dart';
import 'package:chic_secret/utils/constant.dart';
import 'package:chic_secret/utils/security.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

class UnlockVaultScreenViewModel with ChangeNotifier {
  final LocalAuthentication auth = LocalAuthentication();
  final formKey = GlobalKey<FormState>();
  final passwordController = TextEditingController();

  late Vault vault;
  late bool isUnlocking;

  var isPasswordIncorrect = false;

  UnlockVaultScreenViewModel(Vault vault, bool isUnlocking) {
    this.vault = vault;
    this.isUnlocking = isUnlocking;
  }

  unlockWithBiometry(BuildContext context) async {
    var isUsingBiometry = await Security.isPasswordSavedForBiometry(vault);

    if (isUnlocking && isUsingBiometry) {
      bool canCheckBiometrics = await auth.canCheckBiometrics;

      if (canCheckBiometrics) {
        try {
          bool didAuthenticate = await auth.authenticate(
            localizedReason:
                AppTranslations.of(context).text("authenticate_to_unlock"),
          );

          if (didAuthenticate) {
            var password = await Security.getPasswordFromBiometry(vault);

            if (password != null) {
              Navigator.pop(context, password);
            }
          }
        } catch (e) {
          print(e);
        }
      }
    }
  }

  unlockVault(BuildContext context) {
    if (formKey.currentState != null && formKey.currentState!.validate()) {
      try {
        var message = Security.decrypt(
          passwordController.text,
          vault.signature,
        );

        if (message == signature) {
          Navigator.pop(context, passwordController.text);
        } else {
          isPasswordIncorrect = true;
        }
      } catch (e) {
        isPasswordIncorrect = true;
      }
    }

    notifyListeners();
  }
}
