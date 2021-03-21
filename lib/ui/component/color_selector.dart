import 'package:chic_secret/provider/theme_provider.dart';
import 'package:chic_secret/ui/component/color_picker_dialog.dart';
import 'package:chic_secret/utils/chic_platform.dart';
import 'package:chic_secret/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

class ColorSelector extends StatefulWidget {
  final Function(Color) onColorSelected;

  ColorSelector({
    required this.onColorSelected,
  });

  @override
  _ColorSelectorState createState() => _ColorSelectorState();
}

class _ColorSelectorState extends State<ColorSelector> {
  Color _selectedColor = Colors.blue;
  List<Color> _colors = colors.toList();

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context, listen: true);

    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: _colorListSize(),
      children: _generateColorsCircles(themeProvider),
    );
  }

  List<Widget> _generateColorsCircles(ThemeProvider themeProvider) {
    List<Widget> circles = [];

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
                margin: EdgeInsets.all(8),
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

  Widget _generateColorWidget(ThemeProvider themeProvider, Color color) {
    if (_selectedColor == color) {
      // If the color is selected
      return Container(
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
        width: 36,
        height: 36,
        child: Center(
          child: Container(
            width: 31,
            height: 31,
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
    return ChicPlatform.isDesktop() ? 9 : 7;
  }
}
