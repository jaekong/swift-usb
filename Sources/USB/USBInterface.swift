import CLibUSB

/// A USB Interface Descriptor.
public struct USBInterface: CustomStringConvertible {
    private let libusbDescriptor: libusb_interface_descriptor
    public let description: String
    
    public let endpoints: [USBEndpoint]
    
    lazy public private(set) var output: USBEndpoint? = {
        self.endpoints.first { $0.direction == .output }
    }()
    
    lazy public private(set) var input: USBEndpoint? = {
        self.endpoints.first { $0.direction == .input }
    }()
    
    internal init(
        from libusbDescriptor: libusb_interface_descriptor,
        description: String
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

/// A group of USB Interface Descriptors based on the interface's Alternate Settings.
public struct USBInterfaceGroup {
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
                    description: getString(from: alt.iInterface, deviceHandle: deviceHandle) ?? "Unknown"
                )
            )
        }
    }
}

