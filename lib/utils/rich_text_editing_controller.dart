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
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    return textToSpan(text.characters);
  }

  static TextSpan textToSpan(Characters characters) {
    List<TextSpan> textSpanList = [];

    characters.forEach((character) {
      if (numbers.contains(character.toString())) {
        textSpanList.add(TextSpan(style: numberStyle, text: '$character'));
      } else if (uppercase.contains(character.toString())) {
        textSpanList.add(TextSpan(style: uppercaseStyle, text: '$character'));
      } else {
        textSpanList.add(TextSpan(text: '$character'));
      }
    });

    return TextSpan(children: textSpanList);
  }
}
