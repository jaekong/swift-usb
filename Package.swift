// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-usb",
    platforms: [.macOS(.v12), .iOS(.v13)],
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
                .target(name: "CLibUSB")
            ],
        ),
    ],
    
)
