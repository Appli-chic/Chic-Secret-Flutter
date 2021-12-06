import 'package:chic_secret/ui/component/common/chic_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/theme_provider.dart';

class DesktopExpandableMenu extends StatefulWidget {
  final Widget child;
  final String title;
  final Function()? onAddButtonClicked;

  const DesktopExpandableMenu({
    Key? key,
    required this.child,
    required this.title,
    this.onAddButtonClicked,
  }) : super(key: key);

  @override
  _DesktopExpandableMenuState createState() => _DesktopExpandableMenuState();
}

class _DesktopExpandableMenuState extends State<DesktopExpandableMenu> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context, listen: true);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.only(left: 8),
              child: Text(
                widget.title,
                style: TextStyle(
                  color: themeProvider.labelColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ),
            Row(
              children: [
                widget.onAddButtonClicked != null
                    ? ChicIconButton(
                        icon: Icons.add,
                        size: 17,
                        color: themeProvider.textColor,
                        padding: EdgeInsets.all(4),
                        onPressed: widget.onAddButtonClicked,
                        width: 25,
                        height: 25,
                      )
                    : SizedBox.shrink(),
                ChicIconButton(
                  icon:
                      _isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                  size: 17,
                  color: themeProvider.textColor,
                  padding: EdgeInsets.all(4),
                  onPressed: () {
                    _isExpanded = !_isExpanded;
                    setState(() {});
                  },
                  width: 25,
                  height: 25,
                ),
              ],
            ),
          ],
        ),
        Container(
          child: _isExpanded ? widget.child : SizedBox.shrink(),
        ),
      ],
    );
  }
}
