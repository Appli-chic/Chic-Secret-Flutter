import 'package:chic_secret/provider/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

class TagChip extends StatefulWidget {
  final String name;
  final int index;
  final Function(int)? onDelete;

  TagChip({
    required this.name,
    required this.index,
    this.onDelete,
  });

  @override
  _TagChipState createState() => _TagChipState();
}

class _TagChipState extends State<TagChip> {
  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context, listen: true);

    return Container(
      margin: EdgeInsets.only(left: 8, top: 8),
      child: Chip(
        onDeleted: widget.onDelete != null ? _onTagDeleted : null,
        useDeleteButtonTooltip: false,
        backgroundColor: themeProvider.divider,
        label: Text(
          widget.name,
          style: TextStyle(color: themeProvider.textColor),
        ),
        deleteIcon: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Container(
            margin: EdgeInsets.only(left: 4),
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              child: Container(
                padding: EdgeInsets.all(3),
                color: themeProvider.secondBackgroundColor,
                child: Icon(
                  Icons.close,
                  color: themeProvider.textColor,
                  size: 14,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Send back the information the tag got deleted
  _onTagDeleted() {
    widget.onDelete!(widget.index);
  }
}
