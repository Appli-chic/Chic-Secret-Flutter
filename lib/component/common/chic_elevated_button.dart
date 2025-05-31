import 'package:chic_secret/utils/chic_platform.dart';
import 'package:flutter/material.dart';

class ChicElevatedButton extends StatelessWidget {
  final Widget child;
  final Function() onPressed;
  final Color? backgroundColor;

  ChicElevatedButton({
    required this.child,
    required this.onPressed,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        overlayColor: ChicPlatform.isDesktop()
            ? WidgetStateColor.resolveWith((states) => Colors.transparent)
            : null,
        backgroundColor: backgroundColor != null
            ? WidgetStateColor.resolveWith((states) => backgroundColor!)
            : null,
        shape: !ChicPlatform.isDesktop()
            ? WidgetStateProperty.resolveWith(
                (states) => RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                ),
              )
            : null,
        padding: !ChicPlatform.isDesktop()
            ? WidgetStateProperty.resolveWith(
                (states) => EdgeInsets.only(left: 24, right: 24))
            : null,
      ),
      child: child,
      onPressed: onPressed,
    );
  }
}
