import 'package:flutter/material.dart';

/// Create a [Color] object from a color written in hexadecimal
Color getColorFromHex(String color) {
  try {
    return Color(int.parse(color.replaceAll('#', '0xff')));
  } catch (e) {
    print(e.toString());
  }

  return Colors.blue;
}
