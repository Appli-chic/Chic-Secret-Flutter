import 'package:chic_secret/provider/theme_provider.dart';
import 'package:chic_secret/utils/chic_platform.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VaultItem extends StatelessWidget {
  final bool isSelected;

  VaultItem({
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context, listen: true);

    if (ChicPlatform.isDesktop()) {
      return _buildDesktopItem(themeProvider);
    } else {
      return _buildMobileItem(themeProvider);
    }
  }

  Widget _buildMobileItem(ThemeProvider themeProvider) {
    return Card(
      color: themeProvider.secondBackgroundColor,
      child: ListTile(
        horizontalTitleGap: 0,
        leading: Icon(
          Icons.lock,
          color: themeProvider.textColor,
        ),
        title: Text(
          "Vault",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: themeProvider.textColor,
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopItem(ThemeProvider themeProvider) {
    return Container(
      margin: EdgeInsets.only(left: 16, right: 16, top: 2, bottom: 2),
      child: ClipPath(
        clipper: ShapeBorderClipper(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        child: Container(
          color: isSelected ? themeProvider.primaryColor : null,
          padding: EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 4),
          child: Row(
            children: [
              Icon(
                Icons.lock,
                color: isSelected ? Colors.white : themeProvider.textColor,
                size: 13,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  "Vault",
                  style: TextStyle(
                    color: isSelected ? Colors.white : themeProvider.textColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
