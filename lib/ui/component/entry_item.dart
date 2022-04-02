import 'package:chic_secret/localization/app_translations.dart';
import 'package:chic_secret/model/database/entry.dart';
import 'package:chic_secret/provider/theme_provider.dart';
import 'package:chic_secret/ui/component/common/chic_popup_menu_item.dart';
import 'package:chic_secret/utils/chic_platform.dart';
import 'package:chic_secret/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EntryItem extends StatefulWidget {
  final Entry entry;
  final bool isSelected;
  final Function(Entry) onTap;
  final Function(Entry)? onMovingEntryToTrash;
  final Function(Entry)? onMovingToCategory;
  final bool isControlKeyDown;
  final bool isWeakPassword;
  final bool isOldPassword;
  final bool isDuplicatedPassword;

  EntryItem({
    required this.entry,
    required this.isSelected,
    required this.onTap,
    this.onMovingEntryToTrash,
    this.onMovingToCategory,
    this.isControlKeyDown = false,
    this.isWeakPassword = false,
    this.isOldPassword = false,
    this.isDuplicatedPassword = false,
  });

  @override
  _EntryItemState createState() => _EntryItemState();
}

class _EntryItemState extends State<EntryItem> {
  Offset _mousePosition = Offset(0, 0);

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context, listen: true);

    var backgroundColor = !ChicPlatform.isDesktop()
        ? themeProvider.secondBackgroundColor
        : Colors.transparent;

    return MouseRegion(
      onHover: _updateMouseLocation,
      child: GestureDetector(
        onSecondaryTap: () async {
          _onSecondaryClick(context, themeProvider);
        },
        child: Card(
          elevation: ChicPlatform.isDesktop() ? 0 : null,
          margin: EdgeInsets.only(left: 8, right: 8, top: 8),
          color:
              widget.isSelected ? themeProvider.primaryColor : backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6.0),
          ),
          child: ListTile(
            dense: true,
            contentPadding:
                EdgeInsets.only(top: 3, bottom: 3, left: 10, right: 10),
            onTap: () {
              if (widget.isControlKeyDown) {
                _onSecondaryClick(context, themeProvider);
              } else {
                widget.onTap(widget.entry);
              }
            },
            horizontalTitleGap: 0,
            leading: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: getColorFromHex(widget.entry.category!.color),
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
              child: Icon(
                IconData(widget.entry.category!.icon,
                    fontFamily: 'MaterialIcons'),
                color: Colors.white,
              ),
            ),
            title: Container(
              margin: EdgeInsets.only(left: 16),
              child: Text(
                widget.entry.name,
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
                widget.entry.username,
                style: TextStyle(
                  color: widget.isSelected
                      ? themeProvider.textColor
                      : themeProvider.secondTextColor,
                ),
              ),
            ),
            trailing: _onDisplaySecurityInfo(),
          ),
        ),
      ),
    );
  }

  /// Displays if the password is old, weak or duplicated
  Widget _onDisplaySecurityInfo() {
    bool hasSecurityInfo = false;
    Widget weakPassword = SizedBox.shrink();
    Widget oldPassword = SizedBox.shrink();
    Widget duplicatedPassword = SizedBox.shrink();

    if (widget.isWeakPassword) {
      hasSecurityInfo = true;

      weakPassword = Container(
        margin: EdgeInsets.only(left: 4),
        child: Chip(
          backgroundColor: Colors.red,
          label: Text(
            AppTranslations.of(context).text("weak"),
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
            ),
          ),
          labelPadding: EdgeInsets.only(left: 4, right: 4),
        ),
      );
    }

    if (widget.isOldPassword) {
      hasSecurityInfo = true;

      oldPassword = Container(
        margin: EdgeInsets.only(left: 4),
        child: Chip(
          backgroundColor: Colors.deepOrange,
          label: Text(
            AppTranslations.of(context).text("old"),
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
            ),
          ),
          labelPadding: EdgeInsets.only(left: 4, right: 4),
        ),
      );
    }

    if (widget.isDuplicatedPassword) {
      hasSecurityInfo = true;

      duplicatedPassword = Container(
        margin: EdgeInsets.only(left: 4),
        child: Chip(
          backgroundColor: Colors.orange,
          label: Text(
            AppTranslations.of(context).text("duplicated"),
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
            ),
          ),
          labelPadding: EdgeInsets.only(left: 4, right: 4),
        ),
      );
    }

    if (hasSecurityInfo) {
      return Wrap(
        children: [
          weakPassword,
          oldPassword,
          duplicatedPassword,
        ],
      );
    } else {
      return SizedBox.shrink();
    }
  }

  /// Show a menu when the user do a right click on the entry
  _onSecondaryClick(BuildContext context, ThemeProvider themeProvider) async {
    List<PopupMenuEntry> popupEntries = [
      ChicPopupMenuItem(
        onTap: () {
          if (widget.onMovingToCategory != null) {
            widget.onMovingToCategory!(widget.entry);
          }
        },
        title: AppTranslations.of(context).text("move_to"),
      ),
      ChicPopupMenuItem(
        onTap: () {
          if (widget.onMovingEntryToTrash != null) {
            widget.onMovingEntryToTrash!(widget.entry);
          }
        },
        title: AppTranslations.of(context).text("move_to_trash"),
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

  /// Update the mouse location for the secondary click
  void _updateMouseLocation(PointerEvent details) {
    setState(() {
      _mousePosition = details.position;
    });
  }
}
