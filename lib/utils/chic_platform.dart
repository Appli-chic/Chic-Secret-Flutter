import 'dart:io';

class ChicPlatform {
  static bool isDesktop() {
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      return true;
    }

    return false;
  }
}
