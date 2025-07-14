extension StringExtension on String {
  String capitalizeLast() {
    return "${this.substring(0, length - 1)}${this[length - 1].toUpperCase()}";
  }

  String capitalizeFirst() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}
