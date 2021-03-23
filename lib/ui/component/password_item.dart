import 'package:chic_secret/model/database/password.dart';
import 'package:chic_secret/provider/theme_provider.dart';
import 'package:chic_secret/utils/chic_platform.dart';
import 'package:chic_secret/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PasswordItem extends StatelessWidget {
  final Password password;
  final bool isSelected;
  final Function(Password) onTap;

  PasswordItem({
    required this.password,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context, listen: true);

    return Card(
      margin: EdgeInsets.only(left: 16, right: 16, top: 8),
      color: isSelected
          ? themeProvider.primaryColor
          : themeProvider.secondBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6.0),
      ),
      child: ListTile(
        dense: true,
        contentPadding: EdgeInsets.only(top: 4, bottom: 4, left: 10, right: 10),
        onTap: () {
          onTap(password);
        },
        horizontalTitleGap: 0,
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: getColorFromHex(password.category!.color),
            borderRadius: BorderRadius.all(Radius.circular(6)),
          ),
          child: Icon(
            IconData(password.category!.icon, fontFamily: 'MaterialIcons'),
            color: Colors.white,
          ),
        ),
        title: Container(
          margin: EdgeInsets.only(left: 16),
          child: Text(
            password.name,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: ChicPlatform.isDesktop() ? 16 : 18,
              color: themeProvider.textColor,
            ),
          ),
        ),
        subtitle: Container(
          margin: EdgeInsets.only(left: 16),
          child: Text(
            password.username,
            style: TextStyle(
              color: isSelected
                  ? themeProvider.textColor
                  : themeProvider.secondTextColor,
            ),
          ),
        ),
      ),
    );
  }
}
