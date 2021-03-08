import 'package:chic_secret/provider/theme_provider.dart';
import 'package:chic_secret/ui/component/common/chic_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChicTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final bool isPassword;
  final Widget? suffix;
  final FocusNode focus;
  final bool autoFocus;
  final Function(String)? onSubmitted;
  final TextInputAction textInputAction;
  final TextCapitalization textCapitalization;

  ChicTextField({
    required this.controller,
    required this.hint,
    this.isPassword = false,
    this.suffix,
    required this.focus,
    this.autoFocus = false,
    this.onSubmitted,
    this.textInputAction = TextInputAction.next,
    this.textCapitalization = TextCapitalization.none,
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

    return TextField(
      controller: widget.controller,
      focusNode: widget.focus,
      autofocus: widget.autoFocus,
      obscureText: _isHidden,
      textCapitalization: widget.textCapitalization,
      textInputAction: widget.textInputAction,
      onSubmitted: widget.onSubmitted,
      onTap: () {
        widget.focus.requestFocus();
      },
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderSide: BorderSide(color: themeProvider.placeholder),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: themeProvider.primaryColor),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: themeProvider.placeholder),
        ),
        hintText: widget.hint,
        hintStyle: TextStyle(
          color: themeProvider.placeholder,
        ),
        suffixIcon: _displaysSuffixIcon(themeProvider),
      ),
      style: TextStyle(
        color: themeProvider.textColor,
      ),
    );
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
