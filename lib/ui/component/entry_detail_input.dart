import 'package:chic_secret/provider/theme_provider.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EntryDetailInput extends StatefulWidget {
  final String label;
  final String text;
  final bool canCopy;
  final bool isPassword;

  EntryDetailInput({
    required this.label,
    required this.text,
    this.canCopy = false,
    this.isPassword = false,
  });

  @override
  _EntryDetailInputState createState() => _EntryDetailInputState();
}

class _EntryDetailInputState extends State<EntryDetailInput> {
  bool _isPasswordHidden = true;

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context, listen: true);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          child: Text(
            widget.label,
            style: TextStyle(color: themeProvider.secondTextColor),
          ),
        ),
        Row(
          children: [
            _displaysText(themeProvider),
            widget.isPassword
                ? _displaysHidingIcon(themeProvider)
                : SizedBox.shrink(),
            widget.canCopy
                ? _displaysCopyIcon(themeProvider)
                : SizedBox.shrink(),
          ],
        ),
      ],
    );
  }

  /// Displays an icon to show or hide the password
  Widget _displaysHidingIcon(ThemeProvider themeProvider) {
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(6)),
      child: Material(
        color: Colors.transparent,
        child: IconButton(
          icon: Icon(
            _isPasswordHidden ? Icons.visibility : Icons.visibility_off,
            color: themeProvider.textColor,
            size: 20,
          ),
          onPressed: () {
            setState(() {
              _isPasswordHidden = !_isPasswordHidden;
            });
          },
        ),
      ),
    );
  }

  /// Displays an icon to copy the text
  Widget _displaysCopyIcon(ThemeProvider themeProvider) {
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(6)),
      child: Material(
        color: Colors.transparent,
        child: IconButton(
          icon: Icon(
            Icons.copy_rounded,
            color: themeProvider.textColor,
            size: 20,
          ),
          onPressed: () {
            FlutterClipboard.copy(widget.text);
          },
        ),
      ),
    );
  }

  /// Displays the text and hide it if it's a password
  Widget _displaysText(ThemeProvider themeProvider) {
    if (!widget.isPassword) {
      return Expanded(
        child: Container(
          margin: EdgeInsets.only(top: 4),
          child: Text(
            widget.text,
            style: TextStyle(color: themeProvider.textColor),
          ),
        ),
      );
    }

    // If it's a password we display it hidden or not with colors
    if (_isPasswordHidden) {
      return Expanded(
        child: Container(
          margin: EdgeInsets.only(top: 4),
          child: Text(
            widget.text.replaceAll(RegExp(r'.'), "*"),
            style: TextStyle(color: themeProvider.textColor),
          ),
        ),
      );
    } else {
      return Expanded(
        child: Container(
          margin: EdgeInsets.only(top: 4),
          child: Text(
            widget.text,
            style: TextStyle(color: themeProvider.textColor),
          ),
        ),
      );
    }
  }
}
