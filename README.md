# swift-usb

A wrapper package for [libusb](https://libusb.info), a cross-platform USB library.

# Features

- Noncopyable, Nonsendable primitives for safety
- Swift Concurrency
- All Errors are typed throws
- Supports sending data from `Span`, `[UInt8]`, `InlineArray<UInt8>`, and `Data`[^1]
- Embedded Swift support on macOS and Linux[^2][^3]
- Currently only supports sending data via bulk transfer

## Example

```swift
let usb = try USB()
let devices = try usb.getDevices(matching: { device in
    device.productID == myPID
})

guard var device = devices.popLast() else { fatalError() }

try device.open()
try device.claim()

guard let endpoint = device.interfaces.first?.firstOutput else { fatalError() }

// Sending [UInt8] Array
let array: [UInt8] = [0, 1, 2, 3]
try await device.bulkTransfer(array, to: endpoint)

// Sending without copying underlying data with RawSpan
let rawSpan = array.span.bytes
try await device.bulkTransfer(rawSpan, to: endpoint)
```

## Requirements

- Swift 6.4
  - On Apple platforms, requires OS version 27 or higher.
- pkg-config
- libusb-1.0

Note that installing libusb via Homebrew may not properly configure pkg-config. In such case, you may need to configure `PKG_CONFIG_PATH` environment variable to include `/opt/homebrew/lib/pkgconfig`.

## Attribution

- [libusb](https://libusb.info)

[^1]: `Data` is only supported in Full Swift mode with `FoundationEssentials` / `Foundation` module available.
[^2]: Embedded Swift support is not intended for microcontrollers. It's for performance-critical use cases, or in case you need minimal runtime dependency.
[^3]: Windows is currently not supported. It should be possible, but it needs different `Package.swift` configuration, which I can't verify because I don't use Windows.
