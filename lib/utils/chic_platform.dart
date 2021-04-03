import 'dart:io';

class ChicPlatform {

  /// Check if the application is launched on Windows, linux or MacOS
  static bool isDesktop() {
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      return true;
    }

    return false;
  }
}
