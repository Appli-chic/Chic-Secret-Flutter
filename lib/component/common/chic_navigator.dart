import 'package:chic_secret/utils/chic_platform.dart';
import 'package:flutter/material.dart';

class ChicNavigator {
  /// Overrides the [Navigator.pushReplacement] function
  static Future<dynamic> pushReplacement(
      BuildContext context, Widget screen) async {
    await Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  /// Overrides the [Navigator.push] function to manage if the next screen
  /// is going to be a a modal or a full screen
  static Future<dynamic> push(BuildContext context, Widget screen,
      {bool isModal = false}) async {
    if (isModal && ChicPlatform.isDesktop()) {
      return await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return screen;
        },
      );
    } else {
      return await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => screen),
      );
    }
  }
}
