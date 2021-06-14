import 'package:chic_secret/provider/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SecurityItem extends StatelessWidget {
  final int securityIndex;
  final String title;
  final Color color;
  final int number;
  final Function(String, int) onTap;

  const SecurityItem({
    required this.securityIndex,
    required this.title,
    required this.color,
    required this.number,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context, listen: true);

    return Card(
      color: themeProvider.secondBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6.0),
      ),
      child: ListTile(
        onTap: () {
          onTap(title, securityIndex);
        },
        contentPadding: EdgeInsets.only(top: 3, bottom: 3, left: 12, right: 12),
        leading: Container(
          width: 40,
          height: 40,
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.all(Radius.circular(6)),
          ),
          child: Center(
            child: Text(
              number.toString(),
              style: TextStyle(
                color: themeProvider.textColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        title: Container(
          margin: EdgeInsets.only(left: 8),
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: themeProvider.textColor,
            ),
          ),
        ),
      ),
    );
  }
}
