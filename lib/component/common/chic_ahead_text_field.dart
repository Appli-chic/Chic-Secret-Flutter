import 'package:chic_secret/provider/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:provider/provider.dart';

class ChicAheadTextField extends StatelessWidget {
  final TextEditingController controller;
  final Future<List<dynamic>> Function(String) suggestionsCallback;
  final Widget Function(BuildContext, dynamic) itemBuilder;
  final Function(dynamic) onSuggestionSelected;
  final String hint;
  final Function(String) onSubmitted;

  ChicAheadTextField({
    required this.controller,
    required this.suggestionsCallback,
    required this.itemBuilder,
    required this.onSuggestionSelected,
    required this.hint,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context, listen: true);

    return TypeAheadField<dynamic>(
      autoFlipDirection: true,
      builder: (context, controller, focusNode) => TextField(
        controller: controller,
        decoration: InputDecoration(
          border: _getInputBorder(themeProvider.placeholder),
          focusedBorder: _getInputBorder(themeProvider.primaryColor),
          enabledBorder: _getInputBorder(themeProvider.placeholder),
          hintText: hint,
          hintStyle: TextStyle(
            color: themeProvider.placeholder,
          ),
          focusColor: themeProvider.primaryColor,
        ),
        style: TextStyle(
          color: themeProvider.textColor,
        ),
        cursorColor: themeProvider.primaryColor,
        onSubmitted: onSubmitted,
      ),
      suggestionsCallback: suggestionsCallback,
      itemBuilder: itemBuilder,
      onSelected: onSuggestionSelected,
      loadingBuilder: (context) {
        return SizedBox.shrink();
      },
      emptyBuilder: (context) {
        return SizedBox.shrink();
      },
    );
  }

  /// Defines the border [color] of the input
  InputBorder? _getInputBorder(Color color) {
    return OutlineInputBorder(
      borderSide: BorderSide(color: color),
      borderRadius: const BorderRadius.all(
        const Radius.circular(14),
      ),
    );
  }
}
