import CLibUSB

/// Error thrown during USB Transfer.
///
/// - Note: This enumeration contains all of `libusb_transfer_status` cases, and some additional error cases. `libusb_transfer_status` codes match this enumeration's `rawValue`, and additional cases have `rawValue`s of 1000 or greater.
public enum USBTransferError: UInt32, Error, Sendable, CustomStringConvertible {
    case fail = 1
    case timeout = 2
    case cancelled = 3
    case stalled = 4
    case disconnected = 5
    case overflow = 6
    
    case notOpen = 1000
    case notClaimed = 1001
    
    public var description: String {
        switch self {
        case .notOpen: "The device is not open."
        case .notClaimed: "The device is not claimed."
        default:
            if let cString = libusb_error_name(Int32(self.rawValue)) {
                String(cString: cString)
            } else { "Unknown" }
        }
    }
}
