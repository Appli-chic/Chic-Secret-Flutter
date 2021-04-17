import 'package:flutter/material.dart';

class ChicPopupMenuItem extends PopupMenuEntry<int> {
  final String title;
  final Function() onTap;

  ChicPopupMenuItem({
    required this.title,
    required this.onTap,
  });

  @override
  ChicPopupMenuItemState createState() => ChicPopupMenuItemState();

  @override
  double get height => 100;

  @override
  bool represents(int? n) => n == 1 || n == -1;
}

class ChicPopupMenuItemState extends State<ChicPopupMenuItem> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        Navigator.pop<int>(context, 0);
        widget.onTap();
      },
      title: Text(widget.title),
    );
  }
}
