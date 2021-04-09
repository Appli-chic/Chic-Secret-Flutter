import 'package:chic_secret/localization/app_translations.dart';
import 'package:chic_secret/provider/theme_provider.dart';
import 'package:chic_secret/utils/chic_platform.dart';
import 'package:chic_secret/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

import 'common/chic_text_button.dart';

class IconSelector extends StatefulWidget {
  final Color color;
  final Function(IconData) onIconSelected;

  IconSelector({
    required this.color,
    required this.onIconSelected,
  });

  @override
  _IconSelectorState createState() => _IconSelectorState();
}

class _IconSelectorState extends State<IconSelector> {
  IconData _icon = icons[0];
  List<IconData> _icons = icons.toList();

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context, listen: true);

    var crossAxisSize = ChicPlatform.isDesktop() ? 9 : 6;
    var iconsListSize = ChicPlatform.isDesktop() ? 18 : 12;

    return GridView.count(
      physics: BouncingScrollPhysics(),
      shrinkWrap: true,
      crossAxisCount: crossAxisSize,
      children: List.generate(iconsListSize, (index) {
        if (index != iconsListSize - 1) {
          return _displayIcon(
            index,
            _icon,
            _icons,
            widget.color,
            (IconData icon) {
              widget.onIconSelected(icon);
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
                showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (BuildContext context) {
                    return IconPickerDialog(
                      color: widget.color,
                      icon: _icon,
                      onIconChanged: (IconData icon) {
                        if (_icons.indexOf(icon) > iconsListSize - 2 ||
                            _icons.indexOf(icon) == -1) {
                          _icons[0] = icon;
                        }

                        widget.onIconSelected(icon);
                        setState(() {
                          _icon = icon;
                        });
                      },
                    );
                  },
                );
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
  final Function(IconData) onIconChanged;

  IconPickerDialog({
    required this.icon,
    required this.color,
    required this.onIconChanged,
  });

  @override
  _IconPickerDialogState createState() => _IconPickerDialogState();
}

class _IconPickerDialogState extends State<IconPickerDialog> {
  IconData _icon = icons[0];

  @override
  void initState() {
    _icon = widget.icon;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context, listen: true);

    return AlertDialog(
      title: Text(
        AppTranslations.of(context).text("icons"),
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
          physics: BouncingScrollPhysics(),
          crossAxisCount: ChicPlatform.isDesktop() ? 6 : 4,
          children: List.generate(icons.length, (index) {
            return _displayIcon(
              index,
              _icon,
              icons,
              widget.color,
              (IconData icon) {
                widget.onIconChanged(icon);
                setState(() {
                  _icon = icon;
                });
              },
              themeProvider,
            );
          }),
        ),
      ),
      actions: [
        Container(
          margin: EdgeInsets.only(right: 8, bottom: 8),
          child: ChicTextButton(
            child: Text(AppTranslations.of(context).text("ok")),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
      ],
    );
  }
}

/// Displays the icon that will be displayed in the list of icons
/// and in the icon picker
Widget _displayIcon(
  int index,
  IconData icon,
  List<IconData> icons,
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
