import 'package:chic_secret/provider/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

const desktopHeight = 500.0;

class DesktopModal extends StatefulWidget {
  final String title;
  final Widget body;
  final List<Widget> actions;
  final double height;

  DesktopModal({
    required this.title,
    required this.body,
    required this.actions,
    this.height = 500,
  });

  @override
  _DesktopModalState createState() => _DesktopModalState();
}

class _DesktopModalState extends State<DesktopModal> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context, listen: true);

    return AlertDialog(
      title: Text(
        widget.title,
        style: TextStyle(
          color: themeProvider.textColor,
        ),
      ),
      backgroundColor: themeProvider.modalBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      content: Container(
        width: desktopHeight,
        height: widget.height,
        child: Scrollbar(
          controller: _scrollController,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: _scrollController,
            child: widget.body,
          ),
        ),
      ),
      actions: widget.actions,
    );
  }
}
