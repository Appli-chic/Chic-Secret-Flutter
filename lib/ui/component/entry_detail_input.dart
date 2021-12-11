import 'dart:async';
import 'dart:io';

import 'package:chic_secret/localization/app_translations.dart';
import 'package:chic_secret/provider/theme_provider.dart';
import 'package:chic_secret/utils/chic_platform.dart';
import 'package:chic_secret/utils/rich_text_editing_controller.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

Timer? clipboardTimer;

class EntryDetailInputController {
  Function()? hidePassword;

  EntryDetailInputController({this.hidePassword});
}

class EntryDetailInput extends StatefulWidget {
  final EntryDetailInputController? entryDetailInputController;
  final String label;
  final Widget? child;
  final String? text;
  final bool canCopy;
  final bool isPassword;

  EntryDetailInput({
    this.entryDetailInputController,
    required this.label,
    this.text,
    this.child,
    this.canCopy = false,
    this.isPassword = false,
  });

  @override
  _EntryDetailInputState createState() => _EntryDetailInputState();
}

class _EntryDetailInputState extends State<EntryDetailInput> {
  bool _isPasswordHidden = true;
  FToast _toast = FToast();

  @override
  void initState() {
    if (widget.entryDetailInputController != null) {
      widget.entryDetailInputController!.hidePassword = () {
        setState(() {
          _isPasswordHidden = true;
        });
      };
    }

    super.initState();
    _toast.init(context);
  }

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
            widget.text != null
                ? _displaysText(themeProvider)
                : SizedBox.shrink(),
            widget.child != null ? widget.child! : SizedBox.shrink(),
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
            FlutterClipboard.copy(widget.text!);
            _displaysTextCopiedToast(themeProvider);
            _clearClipboard();
          },
        ),
      ),
    );
  }

  /// Clear the clipboard 1min after the password had been copied
  void _clearClipboard() {
    try {
      if (clipboardTimer != null) {
        clipboardTimer!.cancel();
      }

      clipboardTimer = Timer(const Duration(minutes: 1), () {
        if (Platform.isWindows) {
          FlutterClipboard.copy(" ");
        } else {
          Clipboard.setData(ClipboardData());
        }
      });
    } catch (e) {
      print(e);
    }
  }

  /// Show a toast to attest the text had been copied in the clipboard
  void _displaysTextCopiedToast(ThemeProvider themeProvider) {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: themeProvider.divider,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppTranslations.of(context).text("text_copied"),
            style: TextStyle(color: themeProvider.textColor),
          ),
        ],
      ),
    );

    _toast.showToast(
      child: toast,
      gravity: ToastGravity.CENTER,
      toastDuration: Duration(seconds: 2),
    );
  }

  /// Displays the text and hide it if it's a password
  Widget _displaysText(ThemeProvider themeProvider) {
    if (!widget.isPassword) {
      return Expanded(
        child: Container(
          margin: EdgeInsets.only(top: 4),
          child: SelectableText(
            widget.text!,
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
            widget.text!.replaceAll(RegExp(r'.'), "*"),
            style: TextStyle(color: themeProvider.textColor),
          ),
        ),
      );
    } else {
      return Expanded(
        child: Container(
          margin: EdgeInsets.only(top: 4),
          child: SelectableText.rich(
            RichTextEditingController.textToSpan(widget.text!.characters),
          ),
        ),
      );
    }
  }
}
