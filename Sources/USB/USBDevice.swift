import CLibUSB

/// A class that represents a USB device.
///
/// You can get a `USBDevice` from `USB.getDevices(matching:)`
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
    
    internal init?(libusbDevice: OpaquePointer) {
        self.libusbDevice = libusbDevice
        
        let descriptorPointer = UnsafeMutablePointer<libusb_device_descriptor>.allocate(capacity: 1)
        let fetchResult = libusb_get_device_descriptor(libusbDevice, descriptorPointer)
        
        guard fetchResult == 0 else {
            return nil
        }
        
        self.libusbDescriptor = descriptorPointer.pointee
    }
    
    deinit {
        release:
        if isClaimed {
            guard let libusbHandle else { break release }
            
            libusb_release_interface(libusbHandle, 0)
        }
        
        if isOpen {
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
    
    mutating public func open() throws {
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
    
    mutating public func claim() throws {
        guard !isClaimed else { return }
        guard let libusbHandle else { throw USBError.noAvailableDevice }
        
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
    
    public func send(_ data: inout MutableRawSpan, to endpoint: USBEndpoint) {
        let size = data.byteCount
        data.withUnsafeMutableBytes { dataBuffer in
            let pointer = dataBuffer.baseAddress?.assumingMemoryBound(to: UInt8.self)
            let transfer = libusb_alloc_transfer(0)
            
            libusb_fill_bulk_transfer(
                transfer,
                self.libusbHandle,
                endpoint.address,
                pointer,
                Int32(size),
                nil, nil, 1000
            )
            
            libusb_submit_transfer(transfer)
        }
    }
    
    public func send(_ data: borrowing RawSpan, to endpoint: USBEndpoint) {
        let size = data.byteCount
        data.withUnsafeBytes { buffer in
            let pointer = buffer.baseAddress!.assumingMemoryBound(to: UInt8.self)
            let opaque = OpaquePointer(pointer)
            let fauxMutable = UnsafeMutablePointer<UInt8>(opaque)
            let transfer = libusb_alloc_transfer(0)
            
            libusb_fill_bulk_transfer(
                transfer,
                self.libusbHandle,
                endpoint.address,
                fauxMutable,
                Int32(size),
                nil, nil, 1000
            )
            
            libusb_submit_transfer(transfer)
        }
    }
    
    @available(anyAppleOS 26, *)
    public func send(_ bytes: [UInt8], to endpoint: USBEndpoint) {
        send(bytes.span.bytes, to: endpoint)
    }
    
    @available(anyAppleOS 26, *)
    public func send<let count: Int>(_ bytes: [count of UInt8], to endpoint: USBEndpoint) {
        send(bytes.span.bytes, to: endpoint)
    }
    
    internal func getString(from index: UInt8, maxLength: Int32 = 1024) -> String? {
        guard let handle = self.libusbHandle else { return nil }
        return USB::getString(from: index, deviceHandle: handle, maxLength: maxLength)
    }
}
