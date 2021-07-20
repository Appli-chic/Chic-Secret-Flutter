import 'package:chic_secret/provider/theme_provider.dart';
import 'package:chic_secret/utils/chic_platform.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingItem extends StatelessWidget {
  final Color? backgroundColor;
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Function()? onTap;

  const SettingItem({
    this.backgroundColor,
    this.leading,
    this.title,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context, listen: true);

    if (ChicPlatform.isDesktop()) {
      return ListTile(
        horizontalTitleGap: 0,
        leading: leading,
        title: title,
        subtitle: subtitle,
        onTap: onTap,
      );
    } else {
      return Card(
        margin: EdgeInsets.only(left: 8, right: 8, top: 8),
        color: backgroundColor != null
            ? backgroundColor
            : themeProvider.secondBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6.0),
        ),
        child: ListTile(
          horizontalTitleGap: 0,
          leading: leading,
          title: title,
          subtitle: subtitle,
          onTap: onTap,
        ),
      );
    }
  }
}
