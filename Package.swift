// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-usb",
    platforms: [.macOS(.v14), .iOS(.v13)],
    products: [
        .library(name: "USB", targets: ["USB"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-collections.git", from: "1.6.0")
    ],
    targets: [
        .systemLibrary(
            name: "CLibUSB",
            pkgConfig: "libusb-1.0",
            providers: [
                .brew(["libusb"]),
                .apt(["libusb-1.0-0-dev"])
            ],
        ),
        .target(
            name: "USB",
            dependencies: [
                .target(name: "CLibUSB"),
                .product(name: "BasicContainers", package: "swift-collections")
            ],
            swiftSettings: [
                .treatWarning("EmbeddedRestrictions", as: .error),
                .enableExperimentalFeature("MoveOnly"),
                .enableExperimentalFeature("Lifetimes"),
            ]
        ),
        .testTarget(
            name: "USBTest",
            dependencies: [
                .target(name: "USB")
            ]
        )
    ],
    
)
