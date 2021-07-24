import 'package:chic_secret/localization/app_translations.dart';
import 'package:chic_secret/model/database/vault.dart';
import 'package:chic_secret/provider/theme_provider.dart';
import 'package:chic_secret/ui/component/common/chic_navigator.dart';
import 'package:chic_secret/ui/component/common/chic_popup_menu_item.dart';
import 'package:chic_secret/ui/screen/new_vault_screen.dart';
import 'package:chic_secret/ui/screen/vaults_screen.dart';
import 'package:chic_secret/utils/chic_platform.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

class VaultItem extends StatefulWidget {
  final bool isSelected;
  final Vault vault;
  final Function(Vault) onTap;
  final Function()? onVaultChanged;

  VaultItem({
    required this.isSelected,
    required this.vault,
    required this.onTap,
    this.onVaultChanged,
  });

  @override
  _VaultItemState createState() => _VaultItemState();
}

class _VaultItemState extends State<VaultItem> {
  Offset _mousePosition = Offset(0, 0);

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
          widget.onTap(widget.vault);
        },
        horizontalTitleGap: 0,
        leading: Icon(
          Icons.lock,
          color: themeProvider.textColor,
        ),
        title: Text(
          widget.vault.name,
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
      onHover: _updateMouseLocation,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (!widget.isSelected) {
            widget.onTap(widget.vault);
          }
        },
        onSecondaryTap: () async {
          _onSecondaryClick(context, themeProvider);
        },
        child: Container(
          margin: EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 4),
          child: ClipPath(
            clipper: ShapeBorderClipper(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4)),
            ),
            child: Container(
              color:
                  widget.isSelected ? themeProvider.selectionBackground : null,
              padding: EdgeInsets.only(left: 16, right: 16, top: 6, bottom: 6),
              child: Row(
                children: [
                  Icon(
                    vaultPasswordMap[widget.vault.id] != null
                        ? Icons.lock_open
                        : Icons.lock,
                    color: widget.isSelected
                        ? themeProvider.textColor
                        : themeProvider.secondTextColor,
                    size: 13,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      widget.vault.name,
                      style: TextStyle(
                        color: widget.isSelected
                            ? themeProvider.textColor
                            : themeProvider.secondTextColor,
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

  /// Show a menu when the user do a right click on a vault
  _onSecondaryClick(BuildContext context, ThemeProvider themeProvider) async {
    List<PopupMenuEntry> popupEntries = [
      ChicPopupMenuItem(
        onTap: _onEditVault,
        title: AppTranslations.of(context).text("edit"),
      ),
    ];

    await showMenu(
      color: themeProvider.secondBackgroundColor,
      context: context,
      position:
          RelativeRect.fromLTRB(_mousePosition.dx, _mousePosition.dy, 500, 500),
      items: popupEntries,
    );
  }

  /// Call the [NewVaultScreen] to edit the selected vault
  void _onEditVault() async {
    await ChicNavigator.push(
      context,
      NewVaultScreen(vault: widget.vault),
      isModal: true,
    );

    if (widget.onVaultChanged != null) {
      widget.onVaultChanged!();
    }
  }

  /// Update the mouse location for the secondary click
  void _updateMouseLocation(PointerEvent details) {
    setState(() {
      _mousePosition = details.position;
    });
  }
}
