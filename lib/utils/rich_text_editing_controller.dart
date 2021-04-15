import 'package:chic_secret/utils/constant.dart';
import 'package:flutter/material.dart';

class RichTextEditingController extends TextEditingController {
  static TextStyle numberStyle = TextStyle(
    color: Colors.green,
    fontWeight: FontWeight.bold,
  );

  static TextStyle uppercaseStyle = TextStyle(
    color: Colors.blue,
    fontWeight: FontWeight.bold,
  );

  RichTextEditingController({String? text}) : super(text: text);

  @override
  TextSpan buildTextSpan({TextStyle? style, required bool withComposing}) {
    return textToSpan(text.characters);
  }

  /// Transform a text to a span to display the number and uppercase
  /// in a different color.
  static TextSpan textToSpan(Characters characters) {
    List<TextSpan> textSpanList = [];

    characters.forEach((character) {
      if (numbers.contains(character.toString())) {
        // Display number
        textSpanList.add(TextSpan(style: numberStyle, text: '$character'));
      } else if (uppercase.contains(character.toString())) {
        // Display uppercase
        textSpanList.add(TextSpan(style: uppercaseStyle, text: '$character'));
      } else {
        // Display the rest normally
        textSpanList.add(TextSpan(text: '$character'));
      }
    });

    return TextSpan(children: textSpanList);
  }
}
