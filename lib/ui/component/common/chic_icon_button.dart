import 'package:chic_secret/provider/theme_provider.dart';
import 'package:chic_secret/utils/chic_platform.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChicIconButtonType {
  const ChicIconButtonType._(this.index);

  final int index;

  static const ChicIconButtonType noBackground = ChicIconButtonType._(0);

  static const ChicIconButtonType filledRectangle = ChicIconButtonType._(1);
}

class ChicIconButton extends StatelessWidget {
  final IconData icon;
  final Function() onPressed;
  final Color? color;
  final ChicIconButtonType type;

  ChicIconButton({
    required this.icon,
    required this.onPressed,
    this.color,
    this.type = ChicIconButtonType.noBackground,
  });

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context, listen: true);

    if (type == ChicIconButtonType.noBackground) {
      return IconButton(
        splashColor: ChicPlatform.isDesktop() ? Colors.transparent : null,
        focusColor: ChicPlatform.isDesktop() ? Colors.transparent : null,
        highlightColor: ChicPlatform.isDesktop() ? Colors.transparent : null,
        hoverColor: ChicPlatform.isDesktop() ? Colors.transparent : null,
        icon: Icon(
          icon,
          color: color != null ? color! : themeProvider.textColor,
        ),
        onPressed: onPressed,
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
