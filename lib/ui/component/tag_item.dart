import 'package:chic_secret/localization/app_translations.dart';
import 'package:chic_secret/model/database/tag.dart';
import 'package:chic_secret/provider/synchronization_provider.dart';
import 'package:chic_secret/provider/theme_provider.dart';
import 'package:chic_secret/service/entry_tag_service.dart';
import 'package:chic_secret/service/tag_service.dart';
import 'package:chic_secret/ui/component/common/chic_elevated_button.dart';
import 'package:chic_secret/ui/component/common/chic_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

import 'common/chic_popup_menu_item.dart';

class TagItem extends StatefulWidget {
  final Tag? tag;
  final bool isSelected;
  final Function(Tag?) onTap;
  final Function(Tag, bool)? onTagChanged;

  TagItem({
    this.tag,
    required this.isSelected,
    required this.onTap,
    this.onTagChanged,
  });

  @override
  _TagItemState createState() => _TagItemState();
}

class _TagItemState extends State<TagItem> {
  late SynchronizationProvider _synchronizationProvider;
  Offset _mousePosition = Offset(0, 0);

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context, listen: true);
    _synchronizationProvider =
        Provider.of<SynchronizationProvider>(context, listen: true);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onHover: _updateMouseLocation,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (!widget.isSelected) {
            widget.onTap(widget.tag);
          }
        },
        onSecondaryTap: () async {
          if (widget.tag != null) {
            _onSecondaryClick(context, themeProvider);
          }
        },
        child: Container(
          margin: EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 4),
          child: ClipPath(
            clipper: ShapeBorderClipper(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            child: Container(
              color:
                  widget.isSelected ? themeProvider.selectionBackground : null,
              padding: EdgeInsets.only(left: 16, right: 16, top: 6, bottom: 6),
              child: Row(
                children: [
                  Icon(
                    widget.tag != null ? Icons.tag : Icons.apps,
                    color: widget.isSelected
                        ? themeProvider.textColor
                        : themeProvider.secondTextColor,
                    size: 13,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      widget.tag != null
                          ? widget.tag!.name
                          : AppTranslations.of(context).text("none"),
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

  /// Show a menu when the user do a right click on a tag
  _onSecondaryClick(BuildContext context, ThemeProvider themeProvider) async {
    List<PopupMenuEntry> popupEntries = [
      ChicPopupMenuItem(
        onTap: () {
          _renameTag(themeProvider);
        },
        title: AppTranslations.of(context).text("rename"),
      ),
      ChicPopupMenuItem(
        onTap: _onDeletingTag,
        title: AppTranslations.of(context).text("delete"),
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

  /// Rename a tag
  void _renameTag(ThemeProvider themeProvider) async {
    var controller = TextEditingController(text: widget.tag!.name);

    var result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          buttonPadding: EdgeInsets.only(right: 32, bottom: 32),
          backgroundColor: themeProvider.backgroundColor,
          title: Text(AppTranslations.of(context).text("rename")),
          content: ChicTextField(
            controller: controller,
            focus: FocusNode(),
            desktopFocus: FocusNode(),
            autoFocus: true,
            textCapitalization: TextCapitalization.sentences,
            hint: AppTranslations.of(context).text("name"),
            errorMessage: AppTranslations.of(context).text("error_name_empty"),
            validating: (String text) {
              return text.isNotEmpty;
            },
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
            ChicElevatedButton(
              child: Text(
                AppTranslations.of(context).text("rename"),
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    // Rename the tag
    if (result != null && result) {
      var tag = widget.tag!;
      tag.name = controller.text;
      tag.updatedAt = DateTime.now();
      await TagService.update(tag);

      _synchronizationProvider.synchronize();

      if (widget.onTagChanged != null) {
        widget.onTagChanged!(tag, true);
      }
    }
  }

  /// Ask if the tag should be deleted
  void _onDeletingTag() async {
    var result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppTranslations.of(context).text("warning")),
          content: Text(
            AppTranslations.of(context).textWithArgument(
                "warning_message_delete_tag", widget.tag!.name),
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
      // Delete the tag
      await TagService.delete(widget.tag!);
      await EntryTagService.deleteAllFromTag(widget.tag!.id);

      _synchronizationProvider.synchronize();

      if (widget.onTagChanged != null) {
        widget.onTagChanged!(widget.tag!, true);
      }
    }
  }

  /// Update the mouse location for the secondary click
  void _updateMouseLocation(PointerEvent details) {
    setState(() {
      _mousePosition = details.position;
    });
  }
}
