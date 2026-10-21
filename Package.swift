// swift-tools-version: 6.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-usb",
    platforms: [.macOS(.v27), .iOS(.v27)],
    products: [
        .library(name: "USB", targets: ["USB"]),
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
