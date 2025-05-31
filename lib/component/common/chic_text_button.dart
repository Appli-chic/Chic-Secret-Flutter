import 'package:chic_secret/utils/chic_platform.dart';
import 'package:flutter/material.dart';

class ChicTextButton extends StatelessWidget {
  final Widget child;
  final Function() onPressed;

  ChicTextButton({
    required this.child,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: ButtonStyle(
        overlayColor: ChicPlatform.isDesktop()
            ? WidgetStateColor.resolveWith((states) => Colors.transparent)
            : null,
      ),
      child: child,
      onPressed: onPressed,
    );
  }
}
