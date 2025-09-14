import Foundation
import CLibUSB

/// A class that represents a USB device.
///
/// You can get a `USBDevice` from `USB.getDevices(matching:)`
public class USBDevice {
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
        getString(from: libusbDescriptor.iProduct, device: self)
    }
    
    public var manufacturerName: String? {
        getString(from: libusbDescriptor.iManufacturer, device: self)
    }
    
    public var serialNumber: String? {
        getString(from: libusbDescriptor.iSerialNumber, device: self)
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
        if isClaimed { release() }
        if isOpen { close() }
    }
    
    public var configurations: [USBConfiguration] {
        var pointer: UnsafeMutablePointer<libusb_config_descriptor>? = .allocate(capacity: 1)
        var results: [libusb_config_descriptor] = []
        
        let count = libusbDescriptor.bNumConfigurations
        for i in 0..<count {
            libusb_get_config_descriptor(self.libusbDevice, i, &pointer)
            if let pointer {
                results.append(pointer.pointee)
            }
        }
        
        return results.map { USBConfiguration(from: $0, device: self) }
    }
    
    public var interfaces: [USBInterface] {
        self.configurations.flatMap { $0.interfaces }
    }
    
    public func open() throws {
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
    
    public func close() {
        guard let libusbHandle else { return }
        
        if isClaimed { release() }
        
        libusb_close(libusbHandle)
        self.libusbHandle = nil
    }
    
    public func claim() throws {
        guard !isClaimed else { return }
        guard let libusbHandle else { throw USBError.noAvailableDevice }
        
        let result = libusb_claim_interface(libusbHandle, 0)
        if let error = USBError(rawValue: result) {
            throw error
        }
        
        isClaimed = true
    }
    
    public func release() {
        guard isClaimed else { return }
        guard let libusbHandle else { return }
        
        libusb_release_interface(libusbHandle, 0)
        
        isClaimed = false
    }
    
    public func send(_ data: Data, to endpoint: USBEndpoint) {
        send(data.bytes.unsafeLoad(as: [UInt8].self), to: endpoint)
    }
    
    public func send(_ bytes: [UInt8], to endpoint: USBEndpoint) {
        let transfer = libusb_alloc_transfer(0)
        var copy = bytes
        
        libusb_fill_bulk_transfer(
            transfer,
            self.libusbHandle,
            endpoint.address,
            &copy,
            Int32(bytes.count),
            nil, nil, 1000
        )
        
        libusb_submit_transfer(transfer)
    }
}
