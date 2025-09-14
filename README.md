# swift-usb

A wrapper package for [libusb](https://libusb.info), a cross-platform USB library.

Currently only supports sending data via bulk transfer.

## Example

```swift
let usb = try USB(options: [.logLevel(.debug)])
let devices = usb.getDevices(matching: { device in
    device.productID == myPID
})

guard let device = devices.first else { fatalError() }

try device.open()
try device.claim()

guard let endpoint = device.configurations.interfaces.first?.output else { fatalError() }

device.send(data, to: endpoint)
```

## Requirements

- Swift 6.2
- pkg-config
- libusb-1.0

Note that installing libusb via Homebrew may not properly configure pkg-config. In such case, you may need to configure `PKG_CONFIG_PATH` environment variable to include `/opt/homebrew/lib/pkgconfig`.

## Attribution

- [libusb](https://libusb.info)
