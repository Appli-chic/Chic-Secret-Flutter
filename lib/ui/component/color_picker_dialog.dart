import 'package:chic_secret/localization/app_translations.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';

class ColorPickerDialog {
  static Future<bool> colorPickerDialog(
    BuildContext context,
    Color color,
    Function(Color) onColorChange,
  ) async {
    return ColorPicker(
      color: color,
      onColorChanged: (Color color) {
        onColorChange(color);
      },
      width: 40,
      height: 40,
      borderRadius: 8,
      spacing: 5,
      runSpacing: 5,
      wheelDiameter: 155,
      heading: Text(
        AppTranslations.of(context).text("select_color"),
        style: Theme.of(context).textTheme.subtitle1,
      ),
      subheading: Text(
        AppTranslations.of(context).text("select_color_shade"),
        style: Theme.of(context).textTheme.subtitle1,
      ),
      wheelSubheading: Text(
        AppTranslations.of(context).text("select_color_and_shade"),
        style: Theme.of(context).textTheme.subtitle1,
      ),
      showColorCode: true,
      materialNameTextStyle: Theme.of(context).textTheme.caption,
      colorNameTextStyle: Theme.of(context).textTheme.caption,
      colorCodeTextStyle: Theme.of(context).textTheme.caption,
      pickersEnabled: const <ColorPickerType, bool>{
        ColorPickerType.both: false,
        ColorPickerType.primary: true,
        ColorPickerType.accent: false,
        ColorPickerType.bw: false,
        ColorPickerType.custom: false,
        ColorPickerType.wheel: true,
      },
    ).showPickerDialog(
      context,
      constraints:
          const BoxConstraints(minHeight: 460, minWidth: 300, maxWidth: 320),
    );
  }
}
