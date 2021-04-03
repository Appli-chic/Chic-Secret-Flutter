extension StringExtension on String {

  /// Capitalize the last character of a string
  String capitalizeLast() {
    return "${this.substring(0, length - 2)}${this[length - 1].toUpperCase()}";
  }

  /// Capitalize the first character of a string
  String capitalizeFirst() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}
