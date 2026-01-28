// swift-tools-version: 6.2
import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "ShortcutsMacros",
    platforms: [
        .iOS(.v17),
        .watchOS(.v10),
        .macOS(.v13),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "ShortcutsMacros",
            targets: ["ShortcutsMacrosClient"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", from: "510.0.0"),
        .package(url: "https://github.com/apple/swift-testing.git", from: "0.7.0"),
    ],
    targets: [
        .macro(
            name: "ShortcutsMacrosPlugin",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ]
        ),
        .target(
            name: "ShortcutsMacrosClient",
            dependencies: []
        ),
        .testTarget(
            name: "ShortcutsMacrosTests",
            dependencies: [
                "ShortcutsMacrosPlugin",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
                .product(name: "Testing", package: "swift-testing"),
            ]
        ),
    ]
)
