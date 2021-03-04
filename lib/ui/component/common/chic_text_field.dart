import 'package:chic_secret/provider/theme_provider.dart';
import 'package:chic_secret/ui/component/common/chic_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChicTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final bool isPassword;
  final Widget? suffix;

  ChicTextField({
    required this.controller,
    required this.hint,
    this.isPassword = false,
    this.suffix,
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
      obscureText: _isHidden,
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
      if (_isHidden) {
        return ChicIconButton(
          icon: Icons.visibility,
          color: themeProvider.placeholder,
          onPressed: () {
            setState(() {
              _isHidden = !_isHidden;
            });
          },
        );
      } else {
        return ChicIconButton(
          icon: Icons.visibility_off,
          color: themeProvider.placeholder,
          onPressed: () {
            setState(() {
              _isHidden = !_isHidden;
            });
          },
        );
      }
    }

    if (widget.suffix != null) {
      return widget.suffix;
    }

    return null;
  }
}
