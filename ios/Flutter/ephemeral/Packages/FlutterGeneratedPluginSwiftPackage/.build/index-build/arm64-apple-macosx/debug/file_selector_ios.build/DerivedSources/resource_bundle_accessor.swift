import Foundation

extension Foundation.Bundle {
    static let module: Bundle = {
        let mainPath = Bundle.main.bundleURL.appendingPathComponent("file_selector_ios_file_selector_ios.bundle").path
        let buildPath = "/Users/guillaumebelouin/Programmation/personal/flutter/Chic-Secret-Flutter/ios/Flutter/ephemeral/Packages/FlutterGeneratedPluginSwiftPackage/.build/index-build/arm64-apple-macosx/debug/file_selector_ios_file_selector_ios.bundle"

        let preferredBundle = Bundle(path: mainPath)

        guard let bundle = preferredBundle ?? Bundle(path: buildPath) else {
            // Users can write a function called fatalError themselves, we should be resilient against that.
            Swift.fatalError("could not load resource bundle: from \(mainPath) or \(buildPath)")
        }

        return bundle
    }()
}