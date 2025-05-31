#import <Foundation/Foundation.h>

NSBundle* local_auth_darwin_SWIFTPM_MODULE_BUNDLE() {
    NSURL *bundleURL = [[[NSBundle mainBundle] bundleURL] URLByAppendingPathComponent:@"local_auth_darwin_local_auth_darwin.bundle"];

    NSBundle *preferredBundle = [NSBundle bundleWithURL:bundleURL];
    if (preferredBundle == nil) {
      return [NSBundle bundleWithPath:@"/Users/guillaumebelouin/Programmation/personal/flutter/Chic-Secret-Flutter/ios/Flutter/ephemeral/Packages/FlutterGeneratedPluginSwiftPackage/.build/index-build/arm64-apple-macosx/debug/local_auth_darwin_local_auth_darwin.bundle"];
    }

    return preferredBundle;
}