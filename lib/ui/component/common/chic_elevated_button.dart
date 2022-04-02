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
            ? MaterialStateColor.resolveWith((states) => Colors.transparent)
            : null,
        backgroundColor: backgroundColor != null
            ? MaterialStateColor.resolveWith((states) => backgroundColor!)
            : null,
        shape: !ChicPlatform.isDesktop()
            ? MaterialStateProperty.resolveWith(
                (states) => RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                ),
              )
            : null,
        padding:
            MaterialStateProperty.resolveWith((states) => EdgeInsets.only(left: 24, right: 24)),
      ),
      child: child,
      onPressed: onPressed,
    );
  }
}
