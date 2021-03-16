import 'package:chic_secret/provider/theme_provider.dart';
import 'package:chic_secret/utils/chic_platform.dart';
import 'package:chic_secret/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

class IconSelector extends StatefulWidget {
  final Color color;

  IconSelector({
    required this.color,
  });

  @override
  _IconSelectorState createState() => _IconSelectorState();
}

class _IconSelectorState extends State<IconSelector> {
  IconData _icon = icons[0];

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context, listen: true);

    var crossAxisSize = ChicPlatform.isDesktop() ? 9 : 6;
    var iconsListSize = ChicPlatform.isDesktop() ? 18 : 12;

    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: crossAxisSize,
      children: List.generate(iconsListSize, (index) {
        if (index != iconsListSize - 1) {
          return _displayIcon(index, themeProvider);
        } else {
          return MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Container(
              margin: EdgeInsets.all(10),
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
          );
        }
      }),
    );
  }

  Widget _displayIcon(int index, ThemeProvider themeProvider) {
    var child = Container();

    if (_icon == icons[index]) {
      // Display selected icon
      child = Container(
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.all(Radius.circular(6)),
        ),
        child: Icon(
          icons[index],
          color: themeProvider.textColor,
          size: 24,
        ),
      );
    } else {
      // Display icon not selected
      child = Container(
        margin: EdgeInsets.all(8),
        child: Icon(
          icons[index],
          color: themeProvider.textColor,
          size: 24,
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _icon = icons[index];
        });
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: child,
      ),
    );
  }
}
