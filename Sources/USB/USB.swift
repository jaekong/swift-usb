import CLibUSB

public struct USB: ~Copyable, Sendable {
    nonisolated(unsafe) private let context: OpaquePointer
    
    public init() throws(USBError) {
        var ctx: OpaquePointer? = nil
        let initialization = libusb_init(&ctx)
        
        if let error = USBError(rawValue: initialization) {
            throw error
        }
        
        guard let ctx else {
            fatalError("Failed to obtain context from `libusb_init(_:)`.")
        }
        
        context = ctx
    }
    
    deinit {
        libusb_exit(self.context)
    }
    
    @export(interface)
    consuming public func close() {
        libusb_exit(self.context)
        discard self
    }
    
    public func getDevices(
        matching filter: ((borrowing USBDevice) -> Bool)? = nil
    ) throws(USBError) -> UniqueArray<USBDevice> {
        var devicePointers: UnsafeMutablePointer<OpaquePointer?>? = nil
        
        let deviceCount = libusb_get_device_list(nil, &devicePointers)
        
        defer {
            libusb_free_device_list(devicePointers, 1)
        }
        
        guard deviceCount > 0 else {
            if let error = USBError(rawValue: Int32(deviceCount)) {
                throw error
            } else {
                return .init()
            }
        }
        
        guard let devicePointers else {
            fatalError("Cannot fetch USB Device Pointer")
        }
        
        var devicePointer: OpaquePointer? = devicePointers.pointee
        var devices: UniqueArray<USBDevice> = .init()
        
        var pointing = devicePointers
        
        while (devicePointer != nil) {
            defer {
                pointing = pointing.advanced(by: 1)
                devicePointer = pointing.pointee
            }
            
            guard let device = try? USBDevice(libusbDevice: devicePointer!) else {
                continue
            }
            
            if let filter {
                guard filter(device) else { continue }
            }
            
            devices.append(consume device)
        }
        
        return devices
    }
}

public enum USBLogLevel: UInt8, Sendable {
    case none = 0
    case error
    case warning
    case info
    case debug
    
    internal var libusbLogLevel: libusb_log_level {
        libusb_log_level(UInt32(self.rawValue))
    }
}
