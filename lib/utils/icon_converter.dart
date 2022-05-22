import 'dart:io';

import 'package:chic_secret/utils/constant.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class IconConverter {
  static IconData convertMaterialIconToCupertino(IconData icon) {
    if (Platform.isIOS) {
      try {
        var iconIndex = icons.indexOf(icon);
        return cupertinoIcons[iconIndex];
      } catch (e) {
        return convertTrashIconToCupertino(icon);
      }
    } else {
      return icon;
    }
  }

  static IconData convertCupertinoIconToMaterial(IconData icon) {
    if (Platform.isIOS) {
      try {
        var iconIndex = cupertinoIcons.indexOf(icon);
        return icons[iconIndex];
      } catch (e) {
        return icon;
      }
    } else {
      return icon;
    }
  }

  static IconData convertTrashIconToCupertino(IconData icon) {
    if (icon == Icons.delete) {
      return CupertinoIcons.trash_fill;
    }

    return icon;
  }
}
