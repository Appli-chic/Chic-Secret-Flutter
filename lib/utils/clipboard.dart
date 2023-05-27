import 'package:flutter/services.dart';

class FlutterClipboard {
  static Future<void> copy(String text) async {
    if (text.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: text));
      return;
    } else {
      throw ('Please enter a string');
    }
  }

  static Future<String> paste() async {
    ClipboardData? data = await Clipboard.getData('text/plain');
    return data?.text?.toString() ?? "";
  }

  static Future<bool> controlC(String text) async {
    if (text.isNotEmpty) {
      await Clipboard.setData(ClipboardData(text: text));
      return true;
    } else {
      return false;
    }
  }

  static Future<dynamic> controlV() async {
    ClipboardData? data = await Clipboard.getData('text/plain');
    return data;
  }
}