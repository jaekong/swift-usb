import CLibUSB

/// A struct describing an endpoint.
///
/// - Note: This implementation decodes bit-masked data contained in original `bEndpointAddress` of the USB standard. In raw data, lower four bits represent the address of endpoint, and the uppermost bit represents input/output direction.
public struct USBEndpoint: Copyable, Sendable {
    /// Address of this endpoint.
    public let address: UInt8
    
    /// I/O direction of this endpoint.
    public let direction: USBEndpointDirection
    
    internal init(from libusbDescriptor: libusb_endpoint_descriptor) {
        address = libusbDescriptor.bEndpointAddress & 0b1111
        direction = USBEndpointDirection(rawValue: libusbDescriptor.bEndpointAddress & 0x80)!
    }
    
    public init(address: UInt8, direction: USBEndpointDirection) {
        self.address = address
        self.direction = direction
    }
}

/// I/O direction of an endpoint.
public enum USBEndpointDirection: UInt8, Sendable {
    case input = 0x80
    case output = 0x00
}
