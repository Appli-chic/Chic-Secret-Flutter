import 'package:chic_secret/localization/app_translations.dart';
import 'package:chic_secret/model/database/category.dart';
import 'package:chic_secret/model/database/entry.dart';
import 'package:chic_secret/provider/theme_provider.dart';
import 'package:chic_secret/service/entry_service.dart';
import 'package:chic_secret/ui/component/common/chic_navigator.dart';
import 'package:chic_secret/ui/component/common/chic_popup_menu_item.dart';
import 'package:chic_secret/ui/screen/select_category_screen.dart';
import 'package:chic_secret/utils/chic_platform.dart';
import 'package:chic_secret/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EntryItem extends StatefulWidget {
  final Entry entry;
  final bool isSelected;
  final Function(Entry) onTap;
  final Function()? onEntryChanged;

  EntryItem({
    required this.entry,
    required this.isSelected,
    required this.onTap,
    this.onEntryChanged,
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
          margin: EdgeInsets.only(left: 16, right: 16, top: 8),
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
              widget.onTap(widget.entry);
            },
            horizontalTitleGap: 0,
            leading: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: getColorFromHex(widget.entry.category!.color),
                borderRadius: BorderRadius.all(Radius.circular(6)),
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
          ),
        ),
      ),
    );
  }

  /// Show a menu when the user do a right click on the entry
  _onSecondaryClick(BuildContext context, ThemeProvider themeProvider) async {
    List<PopupMenuEntry> popupEntries = [
      ChicPopupMenuItem(
        onTap: _onMovingToCategory,
        title: AppTranslations.of(context).text("move_to"),
      ),
      ChicPopupMenuItem(
        onTap: _onMovingEntryToTrash,
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

  /// Ask if the entry should be move to the trash
  _onMovingEntryToTrash() async {
    var isAlreadyInTrash = widget.entry.category!.isTrash;

    var result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppTranslations.of(context).text("warning")),
          content: Text(
            isAlreadyInTrash
                ? AppTranslations.of(context).textWithArgument(
                    "warning_message_delete_entry_definitely",
                    widget.entry.name)
                : AppTranslations.of(context).textWithArgument(
                    "warning_message_delete_entry", widget.entry.name),
          ),
          actions: [
            TextButton(
              child: Text(
                AppTranslations.of(context).text("cancel"),
              ),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text(
                AppTranslations.of(context).text("delete"),
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (result != null && result) {
      if (!isAlreadyInTrash) {
        // We move the entry to the trash bin
        await EntryService.moveToTrash(widget.entry);
      } else {
        // We delete it definitely
        await EntryService.deleteDefinitively(widget.entry);
      }

      if (widget.onEntryChanged != null) {
        widget.onEntryChanged!();
      }
    }
  }

  /// Call the [SelectCategoryScreen] to move to a new category
  _onMovingToCategory() async {
    var category = await ChicNavigator.push(
      context,
      SelectCategoryScreen(),
      isModal: true,
    );

    if (category != null && category is Category) {
      await EntryService.moveToAnotherCategory(widget.entry, category.id);

      if (widget.onEntryChanged != null) {
        widget.onEntryChanged!();
      }
    }
  }
}
