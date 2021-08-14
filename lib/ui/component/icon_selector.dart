import 'package:chic_secret/localization/app_translations.dart';
import 'package:chic_secret/provider/theme_provider.dart';
import 'package:chic_secret/utils/chic_platform.dart';
import 'package:chic_secret/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

import 'common/chic_text_button.dart';

class IconSelectorController {
  Function(IconData)? onIconChange;

  IconSelectorController({
    this.onIconChange,
  });
}

class IconSelector extends StatefulWidget {
  final IconSelectorController iconSelectorController;
  final Color color;
  final Function(IconData) onIconSelected;
  final IconData icon;

  IconSelector({
    required this.iconSelectorController,
    required this.color,
    required this.onIconSelected,
    required this.icon,
  });

  @override
  _IconSelectorState createState() => _IconSelectorState();
}

class _IconSelectorState extends State<IconSelector> {
  IconData _icon = icons[0];
  List<IconData> _icons = icons.toList();
  var _iconsListSize = 6;

  @override
  void initState() {
    widget.iconSelectorController.onIconChange = _onIconChange;
    super.initState();
  }

  /// Triggered when the icon is being changed
  _onIconChange(IconData icon) {
    _icon = icon;
    var iconListed = _icons
        .sublist(0, _iconsListSize * 2)
        .where((i) => i.codePoint == _icon.codePoint)
        .toList();

    if (iconListed.isNotEmpty) {
      _icon = iconListed[0];
    } else {
      _icons[0] = _icon;
    }
  }

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context, listen: true);
    var shortestSide = MediaQuery.of(context).size.shortestSide;
    double size = 24;

    if (ChicPlatform.isDesktop() && _iconsListSize != 9) {
      _iconsListSize = 9;
      _onIconChange(widget.icon);
    } else if (!ChicPlatform.isDesktop() && shortestSide > 600 && _iconsListSize != 12) {
      _iconsListSize = 12;
      _onIconChange(widget.icon);
    }

    if (!ChicPlatform.isDesktop() && shortestSide > 600) {
      size = 38;
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_iconsListSize, (index) {
            return _displayIcon(
              context,
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
          }),
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_iconsListSize, (index) {
            if (index + _iconsListSize != _iconsListSize * 2 - 1) {
              return _displayIcon(
                context,
                index + _iconsListSize,
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
                            if (_icons.indexOf(icon) > _iconsListSize * 2 - 2 ||
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
                    width: size,
                    height: size,
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
              );
            }
          }),
        ),
      ],
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
    var shortestSide = MediaQuery.of(context).size.shortestSide;
    double width = 320;
    var cells = 4;

    if (ChicPlatform.isDesktop()) {
      width = 500;
      cells = 7;
    } else if (shortestSide > 600) {
      width = 600;
      cells = 8;
    }

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
        width: width,
        height: 460,
        child: GridView.count(
          physics: BouncingScrollPhysics(),
          crossAxisCount: cells,
          children: List.generate(icons.length, (index) {
            return _displayIcon(
              context,
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
  BuildContext context,
  int index,
  IconData icon,
  List<IconData> icons,
  Color color,
  Function(IconData) onTap,
  ThemeProvider themeProvider,
) {
  var child = Container();
  var shortestSide = MediaQuery.of(context).size.shortestSide;
  double size = 24;

  if (!ChicPlatform.isDesktop() && shortestSide > 600) {
    size = 40;
  }

  if (icon == icons[index]) {
    // Display selected icon
    child = Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.all(Radius.circular(6)),
      ),
      child: Icon(
        icons[index],
        color: themeProvider.textColor,
        size: size,
      ),
    );
  } else {
    // Display icon not selected
    child = Container(
      margin: EdgeInsets.all(8),
      child: Icon(
        icons[index],
        color: themeProvider.textColor,
        size: size,
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
