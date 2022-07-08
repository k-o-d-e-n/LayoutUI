// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LayoutUI",
    platforms: [.iOS(.v13), .macOS(.v10_10), .watchOS(.v6), .tvOS(.v13)],
    products: [.library(name: "LayoutUI", targets: ["LayoutUI"])],
    dependencies: [],
    targets: [
        .target(name: "LayoutUI", dependencies: [], exclude: [
            "LayoutBuilders.swift.gyb.swift",
            "RectConstraints.swift.gyb.swift",
            "RectLayouts.swift.gyb.swift",
            "StackLayouts.swift.gyb.swift"
        ]),
        .testTarget(name: "LayoutUITests", dependencies: ["LayoutUI"], exclude: [
            "LayoutUITests.swift.gyb.swift"
        ])
    ]
)
