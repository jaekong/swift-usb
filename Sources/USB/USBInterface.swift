import CLibUSB

/// A USB Interface Descriptor.
public struct USBInterface: CustomStringConvertible {
    internal var libusbDescriptor: libusb_interface_descriptor
    public var description: String {
        getString(from: libusbDescriptor.iInterface, device: device) ?? ""
    }
    unowned internal var device: USBDevice
    
    public var endpoints: [USBEndpoint] = []
    
    public var output: USBEndpoint? {
        self.endpoints.first { $0.direction == .output }
    }
    
    public var input: USBEndpoint? {
        self.endpoints.first { $0.direction == .input }
    }
    
    internal init(from libusbDescriptor: libusb_interface_descriptor, device: USBDevice) {
        self.libusbDescriptor = libusbDescriptor
        self.device = device
        
        let count = libusbDescriptor.bNumEndpoints
        guard count > 0 else { return }
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
    unowned internal var device: USBDevice
    
    public var descriptors: [USBInterface]
    
    internal init(from libusbInterface: libusb_interface, device: USBDevice) {
        self.libusbInterface = libusbInterface
        self.descriptors = []
        self.device = device
        
        let altCount = libusbInterface.num_altsetting
        guard let altPointer = libusbInterface.altsetting else {
            fatalError()
        }
        
        for i in 0..<Int(altCount) {
            let alt = altPointer.advanced(by: i).pointee
            descriptors.append(USBInterface(from: alt, device: device))
        }
    }
}

