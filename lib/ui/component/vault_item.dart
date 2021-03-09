import 'package:chic_secret/model/database/vault.dart';
import 'package:chic_secret/provider/theme_provider.dart';
import 'package:chic_secret/utils/chic_platform.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VaultItem extends StatelessWidget {
  final bool isSelected;
  final Vault vault;
  final Function(Vault) onTap;

  VaultItem({
    required this.isSelected,
    required this.vault,
    required this.onTap,
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
      shape: BeveledRectangleBorder(
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: ListTile(
        onTap: () {
          onTap(vault);
        },
        horizontalTitleGap: 0,
        leading: Icon(
          Icons.lock,
          color: themeProvider.textColor,
        ),
        title: Text(
          vault.name,
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
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        onTap(vault);
      },
      child: Container(
        margin: EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 4),
        child: ClipPath(
          clipper: ShapeBorderClipper(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
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
                    vault.name,
                    style: TextStyle(
                      color:
                          isSelected ? Colors.white : themeProvider.textColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
