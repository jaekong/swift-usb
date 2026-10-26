import CLibUSB

/// Collection of possible error codes.
///
/// - Note: This enumeration contains all of `libusb_error` cases, and some additional error cases. `libusb_error` codes match this enumeration's `rawValue`, and additional cases have `rawValue`s of -1000 or less.
public enum USBError: Int32, Error, Sendable {
    /// I/O Error.
    case ioError = -1
    
    /// Invalid parameter.
    case invalidParameter = -2
    
    /// User has insufficient permissions.
    case accessDenied = -3
    
    /// Device is unavailable, possibly disconnected.
    case deviceUnavailable = -4
    
    /// Entity not found.
    case notFound = -5
    
    /// The requested resource is busy.
    case resourceBusy = -6
    
    /// Operation timed out.
    case timeout = -7
    
    /// Overflow.
    case overflow = -8
    
    /// Pipe error.
    case pipe = -9
    
    /// System call was inturrupted, possibly due to incoming signal.
    case syscallInterrupted = -10
    
    /// Insufficient memory.
    case insufficientMemory = -11
    
    /// Operation is not supported or implemented on current platform.
    case notSupported = -12
    
    /// Unknown error.
    case unknown = -99
    
    /// Unable to claim the device, because the device is not open.
    case isNotOpen = -1000
    
    /// The device is already open.
    case alreadyOpen = -1001
}

extension USBError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .isNotOpen: "The device is not open."
        case .alreadyOpen: "The device is already open."
        default:
            if let cString = libusb_error_name(Int32(self.rawValue)) {
                String(cString: cString)
            } else { "Unknown" }
        }
    }
}
