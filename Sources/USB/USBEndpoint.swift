import CLibUSB

/// An endpoint.
public struct USBEndpoint: Copyable, Sendable {
    public let address: UInt8
    public let direction: USBEndpointDirection
    
    internal init(from libusbDescriptor: libusb_endpoint_descriptor) {
        address = libusbDescriptor.bEndpointAddress & 0b1111
        direction = USBEndpointDirection(rawValue: libusbDescriptor.bEndpointAddress & 0x80)!
    }
}

public enum USBEndpointDirection: UInt8, Sendable {
    case input = 0x80
    case output = 0x00
}
