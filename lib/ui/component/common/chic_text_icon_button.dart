import 'package:chic_secret/utils/chic_platform.dart';
import 'package:flutter/material.dart';

class ChicTextIconButton extends StatelessWidget {
  final Widget label;
  final Widget icon;
  final Function() onPressed;

  ChicTextIconButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      style: ButtonStyle(
        overlayColor: ChicPlatform.isDesktop()
            ? MaterialStateColor.resolveWith((states) => Colors.transparent)
            : null,
      ),
      label: label,
      icon: icon,
      onPressed: onPressed,
    );
  }
}
