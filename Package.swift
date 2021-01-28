// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FileFormatCore",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "FileFormatCore",
            targets: ["FileReader","DataTypes"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/brampf/UInt4.git", from: "1.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "FileReader",
            dependencies: ["DataTypes"]
            ,exclude: ["ReadableProperties"]
            ,swiftSettings: [.define("PARSER_TRACE", .when(configuration: .debug))]
            
        ),
        .target(
            name: "DataTypes",
            dependencies: ["UInt4"]
        ),
        .testTarget(
            name: "FileFormatTests",
            dependencies: ["FileReader"]
            ,swiftSettings: [.define("PARSER_TRACE", .when(configuration: .debug))]
            )
    ]
)
