// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "IBM Security Verify",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "FIDO2",
            targets: ["FIDO2"]),
        .library(
            name: "Adaptive",
            targets: ["Adaptive"]),
        .library(
            name: "Core",
            targets: ["Core"]),
        .library(
            name: "Authentication",
            targets: ["Authentication"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "FIDO2",
            path: "sdk/fido2/Sources",
            exclude: ["Info.plist"]),
        .testTarget(
            name: "FIDO2 Tests",
            dependencies: ["FIDO2"],
            path: "sdk/fido2/Tests"),
        .target(
            name: "Adaptive",
            path: "sdk/adaptive/Sources",
            exclude: ["Info.plist"]),
        .testTarget(
            name: "Adaptive Tests",
            dependencies: ["Adaptive"],
            path: "sdk/adaptive/Tests"),
        .target(
            name: "Core",
            path: "sdk/core/Sources",
            exclude: ["Info.plist"]),
        .testTarget(
            name: "Core Tests",
            dependencies: ["Core"],
            path: "sdk/core/Tests"),
        .target(
            name: "Authentication",
            dependencies: ["Core"],
            path: "sdk/authentication/Sources",
            exclude: ["Info.plist"]),
        .testTarget(
            name: "Authentication Tests",
            dependencies: ["Authentication", "Core"],
            path: "sdk/authentication/Tests"),
    ]
)
