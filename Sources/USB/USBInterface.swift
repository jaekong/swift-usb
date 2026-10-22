import CLibUSB

/// A structure representing a USB interface.
///
/// USB Interfaces are provided by a USB Configuration, and can contain multiple endpoints. Depending on the device, each interface can have different purpose.
///
/// - Note: This struct internally holds `libusb_interface_descriptor`, which is a libusb implementation of the equivalent USB standards.
public struct USBInterface: @unchecked Sendable {
    private let libusbDescriptor: libusb_interface_descriptor
    
    /// Description text for the interface.
    ///
    /// Its contents come from `libusb_interface_descriptor.iInterface`
    public let description: String?
    
    /// Available endpoints.
    public let endpoints: [USBEndpoint]
    
    /// First output endpoint provided by this interface.
    public var firstOutput: USBEndpoint? {
        self.endpoints.first { $0.direction == .output }
    }
    
    /// First input endpoint provided by this interface.
    public var firstInput: USBEndpoint? {
        self.endpoints.first { $0.direction == .input }
    }
    
    /// Index of this interface's alternate setting mode.
    ///
    /// Alternate settings provide a way to categorize interfaces, and address many number of interfaces within a device.
    /// This information is primarily used internally by libusb, and in most cases you can ignore this.
    public var alternateSettingID: UInt8 {
        borrow {
            libusbDescriptor.bAlternateSetting
        }
    }
    
    internal init(
        from libusbDescriptor: libusb_interface_descriptor,
        description: String?
    ) {
        self.libusbDescriptor = libusbDescriptor
        self.description = description
        
        let count = libusbDescriptor.bNumEndpoints
        guard count > 0 else {
            self.endpoints = []
            return
        }
        
        guard let pointer = libusbDescriptor.endpoint else { fatalError() }
        var results: [USBEndpoint] = []
        
        for i in 0..<Int(count) {
            let endpointDescriptor = pointer.advanced(by: i).pointee
            results.append(USBEndpoint(from: endpointDescriptor))
        }
        
        self.endpoints = results
    }
}

extension USBInterface: CustomDebugStringConvertible {
    public var debugDescription: String {
        self.description ?? "<No string descriptor provided.>"
    }
}

/// A group of USB interface descriptors, grouped by the interfaces' alternate setting index.
internal struct USBInterfaceGroup {
    internal let libusbInterface: libusb_interface
    public var descriptors: [USBInterface]
    
    internal init(from libusbInterface: libusb_interface, deviceHandle: OpaquePointer) {
        self.libusbInterface = libusbInterface
        self.descriptors = []
        
        let altCount = libusbInterface.num_altsetting
        guard let altPointer = libusbInterface.altsetting else {
            fatalError()
        }
        
        for i in 0..<Int(altCount) {
            let alt = altPointer.advanced(by: i).pointee
            descriptors.append(
                USBInterface(
                    from: alt,
                    description: getString(from: alt.iInterface, deviceHandle: deviceHandle)
                )
            )
        }
    }
}

