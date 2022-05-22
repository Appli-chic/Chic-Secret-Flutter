import 'dart:io';

import 'package:chic_secret/provider/theme_provider.dart';
import 'package:chic_secret/ui/component/common/chic_icon_button.dart';
import 'package:chic_secret/utils/chic_platform.dart';
import 'package:flutter/cupertino.dart';
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
  final String label;
  final String? hint;
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
  final bool isEnabled;
  final bool isReadOnly;
  final Function()? onTap;
  final bool hasStrengthIndicator;
  final int? maxLines;
  final Function(String)? onTextChanged;
  final TextInputType? keyboardType;
  final FloatingLabelBehavior floatingLabelBehavior;

  ChicTextField({
    required this.controller,
    required this.label,
    this.isPassword = false,
    this.hint,
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
    this.isEnabled = true,
    this.isReadOnly = false,
    this.onTap,
    this.hasStrengthIndicator = false,
    this.maxLines = 1,
    this.onTextChanged,
    this.keyboardType,
    this.floatingLabelBehavior = FloatingLabelBehavior.auto,
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

    if (widget.hasStrengthIndicator) {
      return Column(
        children: [
          _displayInput(themeProvider),
          _displayStrengthIndicator(themeProvider),
        ],
      );
    } else {
      return _displayInput(themeProvider);
    }
  }

  Widget _displayInput(ThemeProvider themeProvider) {
    return RawKeyboardListener(
      focusNode: widget.desktopFocus,
      onKey: _onNext,
      child: TextFormField(
        controller: widget.controller,
        enabled: widget.isEnabled,
        readOnly: widget.isReadOnly,
        focusNode: widget.focus,
        autofocus: widget.autoFocus,
        obscureText: _isHidden,
        textCapitalization: widget.textCapitalization,
        textInputAction: widget.textInputAction,
        keyboardType: widget.keyboardType,
        maxLines: widget.maxLines,
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
          if (widget.onTap != null) {
            widget.onTap!();
          }

          widget.focus.requestFocus();
        },
        onChanged: (String text) {
          if (widget.onTextChanged != null) {
            widget.onTextChanged!(text);
          }

          if (widget.hasStrengthIndicator) {
            setState(() {});
          }
        },
        decoration: InputDecoration(
          focusColor: themeProvider.primaryColor,
          filled: widget.type == ChicTextFieldType.filledRounded,
          fillColor: ChicPlatform.isDesktop()
              ? themeProvider.inputBackgroundColor
              : themeProvider.secondBackgroundColor,
          border: _getInputBorder(themeProvider.placeholder),
          focusedBorder:
              _getInputBorder(themeProvider.primaryColor, isFocused: true),
          errorBorder: _getInputBorder(Colors.red),
          focusedErrorBorder: _getInputBorder(Colors.red, isFocused: true),
          enabledBorder: _getInputBorder(themeProvider.placeholder),
          labelText: widget.label,
          hintText: widget.hint,
          floatingLabelStyle: TextStyle(
            color: themeProvider.secondTextColor,
          ),
          floatingLabelBehavior: widget.floatingLabelBehavior,
          labelStyle: TextStyle(
            color: themeProvider.placeholder,
          ),
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

  Widget _displayStrengthIndicator(ThemeProvider themeProvider) {
    var value = 0.0;
    var colors = [
      themeProvider.secondBackgroundColor,
      themeProvider.secondBackgroundColor,
      themeProvider.secondBackgroundColor,
      themeProvider.secondBackgroundColor,
    ];

    if (widget.controller.text.length == 0) {
      value = 0.0;
    } else if (widget.controller.text.length <= 6) {
      value = 0.25;
      colors[0] = Colors.red;
    } else if (widget.controller.text.length < 10) {
      value = 0.5;
      colors[0] = Colors.orange;
      colors[1] = Colors.orange;
    } else if (widget.controller.text.length < 16) {
      value = 0.75;
      colors[0] = Colors.green;
      colors[1] = Colors.green;
      colors[2] = Colors.green;
    } else {
      value = 1;
      colors[0] = Colors.green;
      colors[1] = Colors.green;
      colors[2] = Colors.green;
      colors[3] = Colors.green;
    }

    if (value == 0.0) {
      return SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.only(top: 16),
      child: Row(
        children: [
          _passwordIndicator(colors[0]),
          SizedBox(width: 8),
          _passwordIndicator(colors[1]),
          SizedBox(width: 8),
          _passwordIndicator(colors[2]),
          SizedBox(width: 8),
          _passwordIndicator(colors[3]),
        ],
      ),
    );
  }

  Widget _passwordIndicator(Color color) {
    return Expanded(
      child: Container(
        height: 6,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.all(Radius.circular(3)),
        ),
      ),
    );
  }

  InputBorder? _getInputBorder(Color color, {isFocused = false}) {
    var borderWidth = isFocused ? 2.0 : 1.0;

    if (widget.type == ChicTextFieldType.outlineBorder) {
      return OutlineInputBorder(
        borderSide: BorderSide(color: color, width: borderWidth),
        borderRadius: const BorderRadius.all(
          const Radius.circular(14),
        ),
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

    // Focus the next input on desktop
    if (isKeyDown &&
        keyCode == LogicalKeyboardKey.tab &&
        widget.nextFocus != null) {
      widget.nextFocus!.requestFocus();
    }
  }

  Widget? _displaysSuffixIcon(ThemeProvider themeProvider) {
    var iconVisible =
        Platform.isIOS ? CupertinoIcons.eye_fill : Icons.visibility;
    var iconInvisible =
        Platform.isIOS ? CupertinoIcons.eye_slash_fill : Icons.visibility_off;

    if (widget.isPassword) {
      return Container(
        margin: EdgeInsets.only(right: 8),
        child: ChicIconButton(
          icon: _isHidden ? iconVisible : iconInvisible,
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
