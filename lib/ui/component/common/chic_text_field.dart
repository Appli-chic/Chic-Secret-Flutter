import 'package:chic_secret/provider/theme_provider.dart';
import 'package:chic_secret/ui/component/common/chic_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class ChicTextFieldType {
  const ChicTextFieldType._(this.index);

  final int index;

  static const ChicTextFieldType outlineBorder = ChicTextFieldType._(0);

  static const ChicTextFieldType filledRounded = ChicTextFieldType._(1);
}

class ChicTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final bool isPassword;
  final Widget? suffix;
  final Widget? prefix;
  final FocusNode focus;
  final FocusNode desktopFocus;
  final FocusNode? nextFocus;
  final bool autoFocus;
  final TextInputAction textInputAction;
  final TextCapitalization textCapitalization;
  final String? errorMessage;
  final bool Function(String)? validating;
  final Function(String)? onSubmitted;
  final ChicTextFieldType type;

  ChicTextField({
    required this.controller,
    required this.hint,
    this.isPassword = false,
    this.suffix,
    this.prefix,
    required this.focus,
    required this.desktopFocus,
    this.nextFocus,
    this.autoFocus = false,
    this.textInputAction = TextInputAction.next,
    this.textCapitalization = TextCapitalization.none,
    this.errorMessage,
    this.validating,
    this.onSubmitted,
    this.type = ChicTextFieldType.outlineBorder,
  });

  @override
  _ChicTextFieldState createState() => _ChicTextFieldState();
}

class _ChicTextFieldState extends State<ChicTextField> {
  var _isHidden = false;

  @override
  void initState() {
    super.initState();

    if (widget.isPassword) {
      _isHidden = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context, listen: true);

    return RawKeyboardListener(
      focusNode: widget.desktopFocus,
      onKey: _onNext,
      child: TextFormField(
        controller: widget.controller,
        focusNode: widget.focus,
        autofocus: widget.autoFocus,
        obscureText: _isHidden,
        textCapitalization: widget.textCapitalization,
        textInputAction: widget.textInputAction,
        validator: (text) {
          if (widget.validating != null && text != null) {
            var result = widget.validating!(text);

            if (!result) {
              return widget.errorMessage;
            }
          }

          return null;
        },
        onFieldSubmitted: widget.onSubmitted,
        onTap: () {
          widget.focus.requestFocus();
        },
        decoration: InputDecoration(
          filled: widget.type == ChicTextFieldType.filledRounded,
          fillColor: widget.type == ChicTextFieldType.filledRounded
              ? themeProvider.secondBackgroundColor
              : null,
          border: _getInputBorder(themeProvider.placeholder),
          focusedBorder: _getInputBorder(themeProvider.primaryColor),
          errorBorder: _getInputBorder(Colors.red),
          enabledBorder: _getInputBorder(themeProvider.placeholder),
          hintText: widget.hint,
          hintStyle: TextStyle(
            color: themeProvider.placeholder,
          ),
          suffixIcon: _displaysSuffixIcon(themeProvider),
          prefixIcon: widget.prefix,
        ),
        style: TextStyle(
          color: themeProvider.textColor,
        ),
      ),
    );
  }

  InputBorder? _getInputBorder(Color color) {
    if (widget.type == ChicTextFieldType.outlineBorder) {
      return OutlineInputBorder(
        borderSide: BorderSide(color: color),
      );
    } else {
      return OutlineInputBorder(
        borderSide: BorderSide(color: Colors.transparent),
        borderRadius: const BorderRadius.all(
          const Radius.circular(6),
        ),
      );
    }
  }

  _onNext(RawKeyEvent event) {
    if (widget.nextFocus == null) {
      return;
    }

    bool isKeyDown;
    switch (event.runtimeType) {
      case RawKeyDownEvent:
        isKeyDown = true;
        break;
      case RawKeyUpEvent:
        isKeyDown = false;
        break;
      default:
        return null;
    }

    LogicalKeyboardKey keyCode;
    switch (event.data.runtimeType) {
      case RawKeyEventData:
        final RawKeyEventData data = event.data;
        keyCode = data.logicalKey;
        break;
      case RawKeyEventDataWindows:
        final RawKeyEventDataWindows data =
            event.data as RawKeyEventDataWindows;
        keyCode = data.logicalKey;
        break;
      case RawKeyEventDataLinux:
        final RawKeyEventDataLinux data = event.data as RawKeyEventDataLinux;
        keyCode = data.logicalKey;
        break;
      case RawKeyEventDataMacOs:
        final RawKeyEventDataMacOs data = event.data as RawKeyEventDataMacOs;
        keyCode = data.logicalKey;
        break;
      default:
        return null;
    }

    if (isKeyDown && keyCode == LogicalKeyboardKey.tab) {
      widget.nextFocus!.requestFocus();
    }
  }

  Widget? _displaysSuffixIcon(ThemeProvider themeProvider) {
    if (widget.isPassword) {
      return Container(
        margin: EdgeInsets.only(right: 8),
        child: ChicIconButton(
          icon: _isHidden ? Icons.visibility : Icons.visibility_off,
          color: themeProvider.placeholder,
          onPressed: () {
            setState(() {
              _isHidden = !_isHidden;
            });
          },
        ),
      );
    }

    if (widget.suffix != null) {
      return widget.suffix;
    }

    return null;
  }
}
