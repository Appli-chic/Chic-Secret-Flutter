import 'package:chic_secret/localization/app_translations.dart';
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
          return _displayIcon(
            index,
            _icon,
            widget.color,
            (IconData icon) {
              setState(() {
                _icon = icon;
              });
            },
            themeProvider,
          );
        } else {
          return MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                // IconPickerDialog
                
              },
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
            ),
          );
        }
      }),
    );
  }
}

class IconPickerDialog extends StatefulWidget {
  final IconData icon;
  final Color color;

  IconPickerDialog({
    required this.icon,
    required this.color,
  });

  @override
  _IconPickerDialogState createState() => _IconPickerDialogState();
}

class _IconPickerDialogState extends State<IconPickerDialog> {
  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context, listen: true);
    IconData _icon = icons[0];

    return AlertDialog(
      title: Text(
        AppTranslations.of(context).text("new_category"),
        style: TextStyle(
          color: themeProvider.textColor,
        ),
      ),
      backgroundColor: themeProvider.secondBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      content: Container(
        width: 320,
        height: 460,
        child: GridView.count(
          crossAxisCount: 6,
          children: List.generate(icons.length, (index) {
            if (index != icons.length - 1) {
              return _displayIcon(
                index,
                _icon,
                widget.color,
                    (IconData icon) {
                  setState(() {
                    _icon = icon;
                  });
                },
                themeProvider,
              );
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
        ),
      ),
    );
  }
}

Widget _displayIcon(
  int index,
  IconData icon,
  Color color,
  Function(IconData) onTap,
  ThemeProvider themeProvider,
) {
  var child = Container();

  if (icon == icons[index]) {
    // Display selected icon
    child = Container(
      margin: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color,
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
      onTap(icons[index]);
    },
    child: MouseRegion(
      cursor: SystemMouseCursors.click,
      child: child,
    ),
  );
}
