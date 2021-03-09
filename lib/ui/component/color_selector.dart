import 'package:chic_secret/provider/theme_provider.dart';
import 'package:chic_secret/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ColorSelector extends StatefulWidget {
  @override
  _ColorSelectorState createState() => _ColorSelectorState();
}

class _ColorSelectorState extends State<ColorSelector> {
  Color _selectedColor = Colors.blue;

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context, listen: true);

    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _generateColorsCircles(themeProvider),
      ),
    );
  }

  List<Widget> _generateColorsCircles(ThemeProvider themeProvider) {
    List<Widget> circles = [];

    for (var color in colors) {
      circles.add(_generateColorWidget(themeProvider, color));
    }

    return circles;
  }

  Widget _generateColorWidget(ThemeProvider themeProvider, Color color) {
    if (_selectedColor == color) {
      // If the color is selected
      return Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Center(
          child: Container(
            width: 31,
            height: 31,
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
        setState(() {
          _selectedColor = color;
        });
      },
      child: Container(
        width: 31,
        height: 31,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}
