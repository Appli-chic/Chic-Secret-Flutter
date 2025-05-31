// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.
//
//  Generated file. Do not edit.
//

import PackageDescription

let package = Package(
    name: "FlutterGeneratedPluginSwiftPackage",
    platforms: [
        .iOS("14.0")
    ],
    products: [
        .library(name: "FlutterGeneratedPluginSwiftPackage", type: .static, targets: ["FlutterGeneratedPluginSwiftPackage"])
    ],
    dependencies: [
        .package(name: "url_launcher_ios", path: "/Users/guillaumebelouin/.pub-cache/hosted/pub.dev/url_launcher_ios-6.3.3/ios/url_launcher_ios"),
        .package(name: "sqlite3_flutter_libs", path: "/Users/guillaumebelouin/.pub-cache/hosted/pub.dev/sqlite3_flutter_libs-0.5.33/darwin/sqlite3_flutter_libs"),
        .package(name: "sqflite_darwin", path: "/Users/guillaumebelouin/.pub-cache/hosted/pub.dev/sqflite_darwin-2.4.2/darwin/sqflite_darwin"),
        .package(name: "shared_preferences_foundation", path: "/Users/guillaumebelouin/.pub-cache/hosted/pub.dev/shared_preferences_foundation-2.5.4/darwin/shared_preferences_foundation"),
        .package(name: "path_provider_foundation", path: "/Users/guillaumebelouin/.pub-cache/hosted/pub.dev/path_provider_foundation-2.4.1/darwin/path_provider_foundation"),
        .package(name: "local_auth_darwin", path: "/Users/guillaumebelouin/.pub-cache/hosted/pub.dev/local_auth_darwin-1.4.3/darwin/local_auth_darwin"),
        .package(name: "pointer_interceptor_ios", path: "/Users/guillaumebelouin/.pub-cache/hosted/pub.dev/pointer_interceptor_ios-0.10.1/ios/pointer_interceptor_ios"),
        .package(name: "file_selector_ios", path: "/Users/guillaumebelouin/.pub-cache/hosted/pub.dev/file_selector_ios-0.5.3+1/ios/file_selector_ios"),
        .package(name: "file_picker", path: "/Users/guillaumebelouin/.pub-cache/hosted/pub.dev/file_picker-8.3.7/ios/file_picker")
    ],
    targets: [
        .target(
            name: "FlutterGeneratedPluginSwiftPackage",
            dependencies: [
                .product(name: "url-launcher-ios", package: "url_launcher_ios"),
                .product(name: "sqlite3-flutter-libs", package: "sqlite3_flutter_libs"),
                .product(name: "sqflite-darwin", package: "sqflite_darwin"),
                .product(name: "shared-preferences-foundation", package: "shared_preferences_foundation"),
                .product(name: "path-provider-foundation", package: "path_provider_foundation"),
                .product(name: "local-auth-darwin", package: "local_auth_darwin"),
                .product(name: "pointer-interceptor-ios", package: "pointer_interceptor_ios"),
                .product(name: "file-selector-ios", package: "file_selector_ios"),
                .product(name: "file-picker", package: "file_picker")
            ]
        )
    ]
)
