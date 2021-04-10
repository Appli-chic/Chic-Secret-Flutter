import 'package:chic_secret/localization/app_translations.dart';
import 'package:chic_secret/model/database/tag.dart';
import 'package:chic_secret/provider/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

class TagItem extends StatelessWidget {
  final Tag? tag;
  final bool isSelected;
  final Function(Tag?) onTap;

  TagItem({
    this.tag,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context, listen: true);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (!isSelected) {
            onTap(tag);
          }
        },
        child: Container(
          margin: EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 4),
          child: ClipPath(
            clipper: ShapeBorderClipper(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4)),
            ),
            child: Container(
              color: isSelected ? themeProvider.primaryColor : null,
              padding: EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 4),
              child: Row(
                children: [
                  Icon(
                    tag != null ? Icons.tag : Icons.apps,
                    color: isSelected ? Colors.white : themeProvider.textColor,
                    size: 13,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      tag != null ? tag!.name : AppTranslations.of(context).text("none"),
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
