import 'package:chic_secret/localization/app_translations.dart';
import 'package:chic_secret/model/database/category.dart';
import 'package:chic_secret/provider/theme_provider.dart';
import 'package:chic_secret/utils/chic_platform.dart';
import 'package:chic_secret/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

class CategoryItem extends StatelessWidget {
  final Category? category;
  final bool? isSelected;
  final Function(Category?) onTap;
  final bool isForcingMobileStyle;

  CategoryItem({
    this.category,
    this.isSelected,
    required this.onTap,
    this.isForcingMobileStyle = false,
  });

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context, listen: true);

    if (ChicPlatform.isDesktop() && !isForcingMobileStyle) {
      return _buildDesktopItem(context, themeProvider);
    } else {
      return _buildMobileItem(themeProvider);
    }
  }

  /// Displays the mobile version of the [CategoryItem]
  Widget _buildMobileItem(ThemeProvider themeProvider) {
    if (category == null) {
      return Container();
    }

    var backgroundColor = _getNotSelectedBackgroundColor(themeProvider);

    if ((ChicPlatform.isDesktop() || isForcingMobileStyle) &&
        isSelected != null &&
        isSelected!) {
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
          onTap(category!);
        },
        horizontalTitleGap: 0,
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: getColorFromHex(category!.color),
            borderRadius: BorderRadius.all(Radius.circular(6)),
          ),
          child: Icon(
            IconData(category!.icon, fontFamily: 'MaterialIcons'),
            color: Colors.white,
          ),
        ),
        title: Container(
          margin: EdgeInsets.only(left: 16),
          child: Text(
            category!.name,
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
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          onTap(category);
        },
        child: Container(
          margin: EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 4),
          child: ClipPath(
            clipper: ShapeBorderClipper(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4)),
            ),
            child: Container(
              color: isSelected!
                  ? _getSelectedBackgroundColor(themeProvider)
                  : null,
              padding: EdgeInsets.only(left: 16, right: 16, top: 6, bottom: 6),
              child: Row(
                children: [
                  Icon(
                    category != null
                        ? IconData(category!.icon, fontFamily: 'MaterialIcons')
                        : Icons.apps,
                    color: isSelected! ? Colors.white : themeProvider.textColor,
                    size: 13,
                  ),
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        category != null
                            ? category!.name
                            : AppTranslations.of(context).text("all"),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isSelected!
                              ? Colors.white
                              : themeProvider.textColor,
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
    if (category != null) {
      return getColorFromHex(category!.color);
    } else {
      return themeProvider.selectionBackground;
    }
  }
}