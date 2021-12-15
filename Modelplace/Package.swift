// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Modelplace",
    platforms: [
        // Add support for all platforms starting from a specific version.
        .macOS(.v10_13),
        .iOS(.v12),
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Modelplace",
            targets: ["Modelplace"]),
    ],
    dependencies: [
        .package(name: "Alamofire", url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.4.0")),
        .package(name: "OAuthSwift", url: "https://github.com/OAuthSwift/OAuthSwift.git", .upToNextMajor(from: "2.2.0")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Modelplace",
            dependencies: ["Alamofire", "OAuthSwift"]),
    ]
)
