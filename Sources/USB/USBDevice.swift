import CLibUSB

/// A struct that represents a USB device.
///
/// Instead of directly initializing, you can get a `USBDevice` from `USB.getDevices(matching:)`.
public struct USBDevice: ~Copyable, ~Sendable {
    internal let libusbDevice: OpaquePointer
    internal let libusbDescriptor: libusb_device_descriptor
    internal var libusbHandle: OpaquePointer?
    
    public var vendorID: UInt16 {
        libusbDescriptor.idVendor
    }
    
    public var productID: UInt16 {
        libusbDescriptor.idProduct
    }
    
    public var deviceClass: USBDeviceClass {
        USBDeviceClass(rawValue: libusbDescriptor.bDeviceClass) ?? .miscellaneous
    }
    
    public var isOpen: Bool {
        self.libusbHandle != nil
    }
    
    public private(set) var isClaimed: Bool = false
    
    public var productName: String? {
        getString(from: libusbDescriptor.iProduct)
    }
    
    public var manufacturerName: String? {
        getString(from: libusbDescriptor.iManufacturer)
    }
    
    public var serialNumber: String? {
        getString(from: libusbDescriptor.iSerialNumber)
    }
    
    internal init(libusbDevice: OpaquePointer) throws(USBError) {
        self.libusbDevice = libusbDevice
        
        let descriptorPointer = UnsafeMutablePointer<libusb_device_descriptor>.allocate(capacity: 1)
        let fetchResult = libusb_get_device_descriptor(libusbDevice, descriptorPointer)
        
        if let error = USBError(rawValue: fetchResult) {
            descriptorPointer.deallocate()
            throw error
        }
        
        self.libusbDescriptor = descriptorPointer.pointee
    }
    
    deinit {
        if let libusbHandle, isClaimed {
            libusb_release_interface(libusbHandle, 0)
        }
        
        if let libusbHandle, isOpen {
            libusb_close(libusbHandle)
        }
    }
    
    public var configurations: [USBConfiguration] {
        guard let libusbHandle else { return [] }
        var pointer: UnsafeMutablePointer<libusb_config_descriptor>? = .allocate(capacity: 1)
        var results: [libusb_config_descriptor] = []
        
        let count = libusbDescriptor.bNumConfigurations
        for i in 0..<count {
            libusb_get_config_descriptor(self.libusbDevice, i, &pointer)
            if let pointer {
                results.append(pointer.pointee)
            }
        }
        
        return results.map {
            USBConfiguration(from: $0, deviceHandle: libusbHandle)
        }
    }
    
    public var interfaces: [USBInterface] {
        self.configurations.flatMap { $0.interfaces }
        
    }
    
    mutating public func open() throws(USBError) {
        guard !isOpen else { throw USBError.alreadyOpen }
        
        let handlePointer = UnsafeMutablePointer<OpaquePointer?>.allocate(capacity: 1)
        let result = libusb_open(libusbDevice, handlePointer)
        if let error = USBError(rawValue: result) {
            throw error
        }
        guard let handle = handlePointer.pointee else {
            throw USBError.unknown
        }
        self.libusbHandle = handle
    }
    
    @export(interface)
    consuming public func close() {
        guard let libusbHandle else {
            discard self
            return
        }
        
        if isClaimed { release() }
        
        libusb_close(libusbHandle)
        self.libusbHandle = nil
        discard self
    }
    
    mutating public func claim() throws(USBError) {
        guard !isClaimed else { return }
        guard let libusbHandle else {
            throw USBError.isNotOpen
        }
        
        let result = libusb_claim_interface(libusbHandle, 0)
        if let error = USBError(rawValue: result) {
            throw error
        }
        
        isClaimed = true
    }
    
    mutating public func release() {
        guard isClaimed else { return }
        guard let libusbHandle else { return }
        
        libusb_release_interface(libusbHandle, 0)
        
        isClaimed = false
    }
    
    internal func getString(from index: UInt8, maxLength: Int32 = 1024) -> String? {
        guard let handle = self.libusbHandle else { return nil }
        return USB::getString(from: index, deviceHandle: handle, maxLength: maxLength)
    }
}
