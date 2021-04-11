import 'package:chic_secret/utils/chic_platform.dart';
import 'package:flutter/material.dart';

class ChicTextIconButton extends StatelessWidget {
  final Widget label;
  final Widget icon;
  final Function() onPressed;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;

  ChicTextIconButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.backgroundColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      style: ButtonStyle(
        overlayColor: ChicPlatform.isDesktop()
            ? MaterialStateColor.resolveWith((states) => Colors.transparent)
            : null,
        backgroundColor: backgroundColor != null
            ? MaterialStateColor.resolveWith((states) => backgroundColor!)
            : null,
        padding: padding != null
            ? MaterialStateProperty.resolveWith((states) => padding)
            : null,
      ),
      label: label,
      icon: icon,
      onPressed: onPressed,
    );
  }
}
