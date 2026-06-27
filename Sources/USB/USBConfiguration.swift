import CLibUSB

public struct USBConfiguration {
    internal var libusbDescriptor: libusb_config_descriptor
    private let deviceHandle: OpaquePointer
    
    public var interfaces: [USBInterface] {
        let count = libusbDescriptor.bNumInterfaces
        let pointer = libusbDescriptor.interface
        
        guard let pointer else { fatalError() }
        
        var interfaces: [libusb_interface] = []
        
        for i in 0..<Int(count) {
            let interface = pointer.advanced(by: i).pointee
            interfaces.append(interface)
        }
        
        return interfaces.flatMap { USBInterfaceGroup(from: $0, deviceHandle: deviceHandle).descriptors }
    }
    
    internal init(
        from libusbDescriptor: libusb_config_descriptor,
        deviceHandle: OpaquePointer
    ) {
        self.libusbDescriptor = libusbDescriptor
        self.deviceHandle = deviceHandle
    }
}

extension USBConfiguration: CustomStringConvertible {
    public var description: String {
        getString(from: libusbDescriptor.iConfiguration, deviceHandle: deviceHandle) ?? ""
    }
}
