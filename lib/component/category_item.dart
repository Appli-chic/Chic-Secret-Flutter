import 'package:chic_secret/component/common/chic_navigator.dart';
import 'package:chic_secret/component/common/chic_popup_menu_item.dart';
import 'package:chic_secret/localization/app_translations.dart';
import 'package:chic_secret/model/database/category.dart';
import 'package:chic_secret/provider/synchronization_provider.dart';
import 'package:chic_secret/provider/theme_provider.dart';
import 'package:chic_secret/service/category_service.dart';
import 'package:chic_secret/service/entry_service.dart';
import 'package:chic_secret/feature/category/new/new_category_screen.dart';
import 'package:chic_secret/utils/chic_platform.dart';
import 'package:chic_secret/utils/color.dart';
import 'package:chic_secret/utils/icon_converter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CategoryItem extends StatefulWidget {
  final Category? category;
  final bool? isSelected;
  final Function(Category?) onTap;
  final bool isForcingMobileStyle;
  final Function()? onCategoryChanged;
  final int nbWeakPasswords;
  final int nbOldPasswords;
  final int nbDuplicatedPasswords;

  CategoryItem({
    this.category,
    this.isSelected,
    required this.onTap,
    this.isForcingMobileStyle = false,
    this.onCategoryChanged,
    this.nbWeakPasswords = 0,
    this.nbOldPasswords = 0,
    this.nbDuplicatedPasswords = 0,
  });

  @override
  _CategoryItemState createState() => _CategoryItemState();
}

class _CategoryItemState extends State<CategoryItem> {
  late SynchronizationProvider _synchronizationProvider;
  Offset _mousePosition = Offset(0, 0);

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context, listen: true);
    _synchronizationProvider =
        Provider.of<SynchronizationProvider>(context, listen: true);

    if (ChicPlatform.isDesktop() && !widget.isForcingMobileStyle) {
      return _buildDesktopItem(context, themeProvider);
    } else {
      return _buildMobileItem(themeProvider);
    }
  }

  Widget _buildMobileItem(ThemeProvider themeProvider) {
    if (widget.category == null) {
      return Container();
    }

    var backgroundColor = _getNotSelectedBackgroundColor(themeProvider);

    if ((ChicPlatform.isDesktop() || widget.isForcingMobileStyle) &&
        widget.isSelected != null &&
        widget.isSelected!) {
      backgroundColor = themeProvider.primaryColor;
    }

    return Card(
      margin: EdgeInsets.only(left: 8, right: 8, top: 8),
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6.0),
      ),
      child: ListTile(
        dense: true,
        contentPadding: ChicPlatform.isDesktop()
            ? EdgeInsets.all(10)
            : EdgeInsets.only(top: 4, bottom: 4, left: 10, right: 10),
        onTap: () {
          widget.onTap(widget.category!);
        },
        horizontalTitleGap: 8,
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: getColorFromHex(widget.category!.color),
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          child: Icon(
            IconConverter.convertMaterialIconToCupertino(
              IconData(widget.category!.icon, fontFamily: 'MaterialIcons'),
            ),
            color: themeProvider.onBackgroundColor,
          ),
        ),
        title: Container(
          margin: EdgeInsets.only(left: 16),
          child: Text(
            widget.category!.name,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: ChicPlatform.isDesktop() ? 16 : 18,
              color: themeProvider.textColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopItem(BuildContext context, ThemeProvider themeProvider) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onHover: _updateMouseLocation,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          widget.onTap(widget.category);
        },
        onSecondaryTap: () async {
          if (widget.category != null && !widget.category!.isTrash) {
            _onSecondaryClick(context, themeProvider);
          }
        },
        child: Container(
          margin: EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 4),
          child: ClipPath(
            clipper: ShapeBorderClipper(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4)),
            ),
            child: Container(
              color: widget.isSelected!
                  ? _getSelectedBackgroundColor(themeProvider)
                  : null,
              padding: EdgeInsets.only(left: 16, right: 16, top: 6, bottom: 6),
              child: Row(
                children: [
                  Icon(
                    widget.category != null
                        ? IconData(widget.category!.icon,
                            fontFamily: 'MaterialIcons')
                        : Icons.apps,
                    color: widget.isSelected!
                        ? themeProvider.onBackgroundColor
                        : themeProvider.secondTextColor,
                    size: 13,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        widget.category != null
                            ? widget.category!.name
                            : AppTranslations.of(context).text("all"),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: widget.isSelected!
                              ? themeProvider.onBackgroundColor
                              : themeProvider.secondTextColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  _displaySecurity(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _displaySecurity() {
    Widget weakPassword = SizedBox.shrink();
    Widget oldPassword = SizedBox.shrink();
    Widget duplicatedPassword = SizedBox.shrink();

    if (widget.nbWeakPasswords > 0) {
      weakPassword = _displaySecurityBubble(
        Colors.red,
        widget.nbWeakPasswords.toString(),
      );
    }

    if (widget.nbOldPasswords > 0) {
      oldPassword = _displaySecurityBubble(
        Colors.deepOrange,
        widget.nbOldPasswords.toString(),
      );
    }

    if (widget.nbDuplicatedPasswords > 0) {
      duplicatedPassword = _displaySecurityBubble(
        Colors.orange,
        widget.nbDuplicatedPasswords.toString(),
      );
    }

    return Row(
      children: [
        weakPassword,
        oldPassword,
        duplicatedPassword,
      ],
    );
  }

  Widget _displaySecurityBubble(Color color, String text) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      padding: EdgeInsets.only(left: 6, right: 6, top: 2, bottom: 2),
      margin: EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
      ),
    );
  }

  Color _getNotSelectedBackgroundColor(ThemeProvider themeProvider) {
    if (ChicPlatform.isDesktop()) {
      return themeProvider.divider;
    } else {
      return themeProvider.secondBackgroundColor;
    }
  }

  Color _getSelectedBackgroundColor(ThemeProvider themeProvider) {
    if (widget.category != null) {
      return getColorFromHex(widget.category!.color);
    } else {
      return themeProvider.selectionBackground;
    }
  }

  _onSecondaryClick(BuildContext context, ThemeProvider themeProvider) async {
    List<PopupMenuEntry> popupEntries = [
      ChicPopupMenuItem(
        onTap: _onEditCategory,
        title: AppTranslations.of(context).text("edit"),
      ),
      ChicPopupMenuItem(
        onTap: _onDeletingCategory,
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

  void _onDeletingCategory() async {
    var result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppTranslations.of(context).text("warning")),
          content: Text(
            AppTranslations.of(context).textWithArgument(
                "warning_message_delete_category", widget.category!.name),
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
      await EntryService.moveToTrashAllEntriesFromCategory(widget.category!);
      await CategoryService.delete(widget.category!);

      _synchronizationProvider.synchronize();

      if (widget.onCategoryChanged != null) {
        widget.onCategoryChanged!();
      }
    }
  }

  void _onEditCategory() async {
    var category = await ChicNavigator.push(
      context,
      NewCategoryScreen(category: widget.category, previousPageTitle: ""),
      isModal: true,
    );

    if (category != null && category is Category) {
      if (widget.onCategoryChanged != null) {
        widget.onCategoryChanged!();
      }
    }
  }

  void _updateMouseLocation(PointerEvent details) {
    setState(() {
      _mousePosition = details.position;
    });
  }
}
