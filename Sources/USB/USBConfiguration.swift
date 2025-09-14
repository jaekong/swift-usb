import CLibUSB

public class USBConfiguration: CustomStringConvertible {
    internal var libusbDescriptor: libusb_config_descriptor
    unowned internal var device: USBDevice
    
    public var description: String {
        getString(from: libusbDescriptor.iConfiguration, device: device) ?? ""
    }
    
    public var interfaces: [USBInterface] {
        let count = libusbDescriptor.bNumInterfaces
        let pointer = libusbDescriptor.interface
        
        guard let pointer else { fatalError() }
        
        var interfaces: [libusb_interface] = []
        
        for i in 0..<Int(count) {
            let interface = pointer.advanced(by: i).pointee
            interfaces.append(interface)
        }
        
        return interfaces.flatMap { USBInterfaceGroup(from: $0, device: device).descriptors }
    }
    
    internal init(from libusbDescriptor: libusb_config_descriptor, device: USBDevice) {
        self.libusbDescriptor = libusbDescriptor
        self.device = device
    }
    
    deinit {
        libusb_free_config_descriptor(&libusbDescriptor)
    }
}
