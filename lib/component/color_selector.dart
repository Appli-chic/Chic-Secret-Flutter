import 'package:chic_secret/localization/app_translations.dart';
import 'package:chic_secret/provider/theme_provider.dart';
import 'package:chic_secret/utils/chic_platform.dart';
import 'package:chic_secret/utils/constant.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ColorSelectorController {
  Function(Color)? onColorChange;

  ColorSelectorController({
    this.onColorChange,
  });
}

class ColorSelector extends StatefulWidget {
  final ColorSelectorController colorSelectorController;
  final Function(Color) onColorSelected;
  final Color color;

  ColorSelector({
    required this.colorSelectorController,
    required this.onColorSelected,
    required this.color,
  });

  @override
  _ColorSelectorState createState() => _ColorSelectorState();
}

class _ColorSelectorState extends State<ColorSelector> {
  Color _selectedColor = Colors.blue;
  List<Color> _colors = colors.toList();

  @override
  void initState() {
    widget.colorSelectorController.onColorChange = _changeColorSelection;

    _changeColorSelection(widget.color);
    super.initState();
  }

  _changeColorSelection(Color color) {
    _selectedColor = color;
    var colorsListed = _colors
        .where((c) =>
            c.value.toRadixString(16) == _selectedColor.value.toRadixString(16))
        .toList();

    if (colorsListed.isNotEmpty) {
      if (_colors.indexOf(colorsListed[0]) >= _colorListSize() - 1) {
        _colors[0] = _selectedColor;
      } else {
        _selectedColor = colorsListed[0];
      }
    } else {
      _colors[0] = _selectedColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context, listen: true);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: _generateColorsCircles(themeProvider),
    );
  }

  /// Generates a list of selectable color circles
  List<Widget> _generateColorsCircles(ThemeProvider themeProvider) {
    List<Widget> circles = [];

    var shortestSide = MediaQuery.of(context).size.shortestSide;
    double size = 31;

    if (!ChicPlatform.isDesktop() && shortestSide > 600) {
      size = 70;
    }

    for (var colorIndex = 0; colorIndex < _colorListSize(); colorIndex++) {
      if (colorIndex != _colorListSize() - 1) {
        // Show Color
        circles.add(
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Container(
              margin: EdgeInsets.only(left: 6, right: 6),
              child: _generateColorWidget(themeProvider, _colors[colorIndex]),
            ),
          ),
        );
      } else {
        // Show get more colors button
        circles.add(
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () async {
                await ColorPickerDialog.colorPickerDialog(
                  context,
                  _selectedColor,
                  _onColorSelected,
                );
              },
              child: Container(
                width: size,
                height: size,
                margin: EdgeInsets.only(left: 2, top: 2, bottom: 2),
                child: ClipOval(
                  child: Container(
                    color: themeProvider.textColor,
                    child: Icon(
                      Icons.add,
                      color: themeProvider.backgroundColor,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }

    return circles;
  }

  /// Displays A single color circle
  Widget _generateColorWidget(ThemeProvider themeProvider, Color color) {
    var shortestSide = MediaQuery.of(context).size.shortestSide;
    double size = 36;

    if (!ChicPlatform.isDesktop() && shortestSide > 600) {
      size = 70;
    }

    if (_selectedColor == color) {
      // If the color is selected
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Center(
          child: Container(
            margin: EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: themeProvider.backgroundColor,
                width: 2,
              ),
            ),
          ),
        ),
      );
    }

    // If it's not selected
    return GestureDetector(
      onTap: () {
        _onColorSelected(color);
      },
      child: Container(
        width: size,
        height: size,
        child: Center(
          child: Container(
            width: size - 5,
            height: size - 5,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        ),
      ),
    );
  }

  _onColorSelected(Color color) {
    // Check if the color exist in the list
    var indexColor = _colors.indexOf(color);
    if (indexColor == -1 || indexColor > _colorListSize()) {
      _colors[0] = color;
    }

    widget.onColorSelected(color);

    setState(() {
      _selectedColor = color;
    });
  }

  int _colorListSize() {
    try {
      var shortestSide = MediaQuery.of(context).size.shortestSide;

      if (ChicPlatform.isDesktop()) {
        return 10;
      } else if (shortestSide > 600) {
        return 12;
      }
    } catch (e) {}

    return 7;
  }
}

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
        style: Theme.of(context).textTheme.labelLarge,
      ),
      subheading: Text(
        AppTranslations.of(context).text("select_color_shade"),
        style: Theme.of(context).textTheme.labelLarge,
      ),
      wheelSubheading: Text(
        AppTranslations.of(context).text("select_color_and_shade"),
        style: Theme.of(context).textTheme.labelLarge,
      ),
      showColorCode: true,
      materialNameTextStyle: Theme.of(context).textTheme.labelSmall,
      colorNameTextStyle: Theme.of(context).textTheme.labelSmall,
      colorCodeTextStyle: Theme.of(context).textTheme.labelSmall,
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
