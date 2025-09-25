import Foundation
import CLibUSB

public class USB {
    public init() throws {
//        var libusbOptions = options.map { $0.libusbOption }
        
//        let initialization = libusb_init_context(nil, &libusbOptions, Int32(libusbOptions.count))
        let initialization = libusb_init(nil)
        
        if let error = USBError(rawValue: initialization) {
            throw error
        }
    }
    
    public func getDevices(matching filter: ((USBDevice) -> Bool)?) -> [USBDevice] {
        var devicePointers: UnsafeMutablePointer<OpaquePointer?>? = nil
        let deviceCount = libusb_get_device_list(nil, &devicePointers)
        
        guard deviceCount > 0 else {
            return []
        }
        
        guard let devicePointers else {
            fatalError("Cannot fetch USB Device Pointer")
        }
        
        var devicePointer: OpaquePointer? = devicePointers.pointee
        var devices: [USBDevice] = []
        
        var pointing = devicePointers
        
        while (devicePointer != nil) {
            defer {
                pointing = pointing.advanced(by: 1)
                devicePointer = pointing.pointee
            }
            
            guard let device = USBDevice(libusbDevice: devicePointer!) else {
                continue
            }
            
            if let filter {
                guard filter(device) else { continue }
            }
            
            devices.append(device)
        }
        
        libusb_free_device_list(devicePointers, 1)
        
        return devices
    }
}

//public enum USBOption {
//    case logLevel(USBLogLevel)
//    
//    internal var libusbOption: libusb_init_option {
//        switch self {
//        case .logLevel(let level):
//            libusb_init_option(option: LIBUSB_OPTION_LOG_LEVEL, value: .init(ival: Int32(level.libusbLogLevel.rawValue)))
//        }
//    }
//}

public enum USBLogLevel: UInt8 {
    case none = 0
    case error
    case warning
    case info
    case debug
    
    internal var libusbLogLevel: libusb_log_level {
        libusb_log_level(UInt32(self.rawValue))
    }
}
