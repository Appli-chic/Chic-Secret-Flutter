import 'package:chic_secret/utils/constant.dart';
import 'package:flutter/material.dart';

class RichTextEditingController extends TextEditingController {
  TextStyle numberStyle = TextStyle(
    color: Colors.green,
    fontWeight: FontWeight.bold,
  );

  TextStyle uppercaseStyle = TextStyle(
    color: Colors.blue,
    fontWeight: FontWeight.bold,
  );

  @override
  TextSpan buildTextSpan({TextStyle? style, required bool withComposing}) {
    var characters = text.characters;
    List<TextSpan> textSpanList = [];

    characters.forEach((character) {
      if (numbers.contains(character.toString())) {
        // Display number
        textSpanList.add(TextSpan(style: numberStyle, text: '$character'));
      } else if(uppercase.contains(character.toString())) {
        // Display uppercase
        textSpanList.add(TextSpan(style: uppercaseStyle, text: '$character'));
      }else {
        // Display the rest normally
        textSpanList.add(TextSpan(text: '$character'));
      }
    });

    return TextSpan(children: textSpanList);
  }
}