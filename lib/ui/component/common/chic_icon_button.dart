import 'package:chic_secret/provider/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChicIconButton extends StatelessWidget {
  final IconData icon;
  final Function() onPressed;
  final Color? color;

  ChicIconButton({
    required this.icon,
    required this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context, listen: true);

    return IconButton(
      icon: Icon(
        icon,
        color: color != null ? color! : themeProvider.textColor,
      ),
      onPressed: onPressed,
    );
  }
}
