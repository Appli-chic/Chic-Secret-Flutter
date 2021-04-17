import 'package:chic_secret/localization/app_translations.dart';
import 'package:chic_secret/model/database/category.dart';
import 'package:chic_secret/provider/theme_provider.dart';
import 'package:chic_secret/ui/component/common/chic_navigator.dart';
import 'package:chic_secret/ui/screen/new_category_screen.dart';
import 'package:chic_secret/utils/chic_platform.dart';
import 'package:chic_secret/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

class CategoryItem extends StatefulWidget {
  final Category? category;
  final bool? isSelected;
  final Function(Category?) onTap;
  final bool isForcingMobileStyle;
  final Function()? onCategoryChanged;

  CategoryItem({
    this.category,
    this.isSelected,
    required this.onTap,
    this.isForcingMobileStyle = false,
    this.onCategoryChanged,
  });

  @override
  _CategoryItemState createState() => _CategoryItemState();
}

class _CategoryItemState extends State<CategoryItem> {
  Offset _mousePosition = Offset(0, 0);

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context, listen: true);

    if (ChicPlatform.isDesktop() && !widget.isForcingMobileStyle) {
      return _buildDesktopItem(context, themeProvider);
    } else {
      return _buildMobileItem(themeProvider);
    }
  }

  /// Displays the mobile version of the [CategoryItem]
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
      margin: EdgeInsets.only(left: 16, right: 16, top: 8),
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
        horizontalTitleGap: 0,
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: getColorFromHex(widget.category!.color),
            borderRadius: BorderRadius.all(Radius.circular(6)),
          ),
          child: Icon(
            IconData(widget.category!.icon, fontFamily: 'MaterialIcons'),
            color: Colors.white,
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

  /// Displays the desktop version of the [CategoryItem]
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
                        ? themeProvider.textColor
                        : themeProvider.secondTextColor,
                    size: 13,
                  ),
                  Flexible(
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
                              ? themeProvider.textColor
                              : themeProvider.secondTextColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
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

  /// Retrieve the [CategoryItem]'s background color when the category is not selected
  /// depending of the operating system.
  Color _getNotSelectedBackgroundColor(ThemeProvider themeProvider) {
    if (ChicPlatform.isDesktop()) {
      return themeProvider.divider;
    } else {
      return themeProvider.secondBackgroundColor;
    }
  }

  /// Retrieve the [CategoryItem]'s background color depending of
  /// the operating system.
  Color _getSelectedBackgroundColor(ThemeProvider themeProvider) {
    if (widget.category != null) {
      return getColorFromHex(widget.category!.color);
    } else {
      return themeProvider.selectionBackground;
    }
  }

  /// Show a menu when the user do a right click on the category
  _onSecondaryClick(BuildContext context, ThemeProvider themeProvider) async {
    List<PopupMenuEntry> popupEntries = [
      PopupMenuItem(
        child: GestureDetector(
          onTap: _onEditCategory,
          child: Text(AppTranslations.of(context).text("edit")),
        ),
      ),
      PopupMenuItem(
        child: GestureDetector(
          onTap: () {},
          child: Text(AppTranslations.of(context).text("delete")),
        ),
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

  void _onEditCategory() async {
    var category = await ChicNavigator.push(
      context,
      NewCategoryScreen(category: widget.category),
      isModal: true,
    );

    if (category != null && category is Category) {
      if (ChicPlatform.isDesktop() && widget.onCategoryChanged != null) {
        widget.onCategoryChanged!();
      }
    }

    Navigator.pop(context);
  }

  /// Update the mouse location for the secondary click
  void _updateMouseLocation(PointerEvent details) {
    setState(() {
      _mousePosition = details.position;
    });
  }
}
