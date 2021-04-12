import 'package:chic_secret/model/database/vault.dart';
import 'package:chic_secret/provider/theme_provider.dart';
import 'package:chic_secret/utils/chic_platform.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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

  /// Displays the vault item for the mobile version
  Widget _buildMobileItem(ThemeProvider themeProvider) {
    return Card(
      margin: EdgeInsets.only(left: 16, right: 16, top: 8),
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

  /// Displays the vault item for the desktop version
  Widget _buildDesktopItem(ThemeProvider themeProvider) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if(!isSelected) {
            onTap(vault);
          }
        },
        child: Container(
          margin: EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 4),
          child: ClipPath(
            clipper: ShapeBorderClipper(
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
            child: Container(
              color: isSelected ? themeProvider.primaryColor : null,
              padding: EdgeInsets.only(left: 16, right: 16, top: 6, bottom: 6),
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
      ),
    );
  }
}
