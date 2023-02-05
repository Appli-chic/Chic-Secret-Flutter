import 'package:chic_secret/provider/theme_provider.dart';
import 'package:chic_secret/utils/chic_platform.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// The type defines the global the design of the button
class ChicIconButtonType {
  const ChicIconButtonType._(this.index);

  final int index;

  /// Represents a button without any background
  static const ChicIconButtonType noBackground = ChicIconButtonType._(0);

  /// Represents a button with a filled background shaped into a rectangle
  static const ChicIconButtonType filledRectangle = ChicIconButtonType._(1);

  /// Represents a button with a filled background shaped into a circle
  static const ChicIconButtonType filledCircle = ChicIconButtonType._(2);
}

class ChicIconButton extends StatelessWidget {
  final IconData icon;
  final Function()? onPressed;
  final Color? color;
  final ChicIconButtonType type;
  final double? size;
  final EdgeInsetsGeometry padding;
  final double? width;
  final double? height;

  ChicIconButton({
    required this.icon,
    required this.onPressed,
    this.color,
    this.type = ChicIconButtonType.noBackground,
    this.size,
    this.padding = const EdgeInsets.all(8.0),
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context, listen: true);

    if (type == ChicIconButtonType.noBackground) {
      return SizedBox(
        width: width,
        height: height,
        child: IconButton(
          padding: padding,
          splashColor: ChicPlatform.isDesktop() ? Colors.transparent : null,
          focusColor: ChicPlatform.isDesktop() ? Colors.transparent : null,
          highlightColor: ChicPlatform.isDesktop() ? Colors.transparent : null,
          hoverColor: ChicPlatform.isDesktop() ? Colors.transparent : null,
          icon: Icon(
            icon,
            color: color != null ? color! : themeProvider.textColor,
            size: size,
          ),
          onPressed: onPressed,
        ),
      );
    }
    if (type == ChicIconButtonType.filledCircle) {
      return Container(
        width: 35,
        height: 35,
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(20),
        ),
        child: IconButton(
          splashColor: ChicPlatform.isDesktop() ? Colors.transparent : null,
          focusColor: ChicPlatform.isDesktop() ? Colors.transparent : null,
          highlightColor: ChicPlatform.isDesktop() ? Colors.transparent : null,
          hoverColor: ChicPlatform.isDesktop() ? Colors.transparent : null,
          icon: Icon(
            icon,
            color: color != null ? color! : themeProvider.textColor,
          ),
          iconSize: 18,
          onPressed: onPressed,
        ),
      );
    } else {
      return Container(
        padding: EdgeInsets.only(left: 4, right: 4),
        decoration: BoxDecoration(
          color: themeProvider.primaryColor,
          borderRadius: BorderRadius.circular(6),
        ),
        child: IconButton(
          splashColor: ChicPlatform.isDesktop() ? Colors.transparent : null,
          focusColor: ChicPlatform.isDesktop() ? Colors.transparent : null,
          highlightColor: ChicPlatform.isDesktop() ? Colors.transparent : null,
          hoverColor: ChicPlatform.isDesktop() ? Colors.transparent : null,
          icon: Icon(
            icon,
            color: color != null ? color! : themeProvider.textColor,
          ),
          onPressed: onPressed,
        ),
      );
    }
  }
}
