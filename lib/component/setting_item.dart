import 'package:chic_secret/provider/theme_provider.dart';
import 'package:chic_secret/utils/chic_platform.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingItem extends StatelessWidget {
  final Color? backgroundColor;
  final IconData? leading;
  final Widget? leadingIcon;
  final String title;
  final String? subtitle;
  final Color? tint;
  final Function()? onTap;

  const SettingItem({
    this.backgroundColor,
    this.leading,
    this.leadingIcon,
    required this.title,
    this.subtitle,
    this.tint,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context, listen: true);

    if (ChicPlatform.isDesktop()) {
      return ListTile(
        horizontalTitleGap: 8,
        leading: _displayLeading(themeProvider),
        title: _displayTitle(themeProvider),
        subtitle: _displaySubtitle(themeProvider),
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
          horizontalTitleGap: 8,
          leading: _displayLeading(themeProvider),
          title: _displayTitle(themeProvider),
          subtitle: _displaySubtitle(themeProvider),
          onTap: onTap,
        ),
      );
    }
  }

  Widget? _displayLeading(ThemeProvider themeProvider) {
    if (leadingIcon != null) {
      return leadingIcon;
    }

    if (leading != null) {
      return Icon(
        leading,
        color: tint == null ? themeProvider.textColor : tint,
      );
    }

    return null;
  }

  Widget? _displayTitle(ThemeProvider themeProvider) {
    return Text(
      title,
      style: TextStyle(color: tint == null ? themeProvider.textColor : tint),
    );
  }

  Widget? _displaySubtitle(ThemeProvider themeProvider) {
    if (subtitle == null) return null;

    return Text(subtitle!,
        style: TextStyle(color: themeProvider.secondTextColor));
  }
}
