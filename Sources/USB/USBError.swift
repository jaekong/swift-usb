import Foundation
import CLibUSB

public enum USBError: Int32, Error {
    /** Input/output error */
    case ioError = -1
    /** Invalid parameter */
    case invalidParameter = -2
    /** Access denied (insufficient permissions) */
    case accessDenied = -3
    /** No such device (it may have been disconnected) */
    case deviceUnavailable = -4
    /** Entity not found */
    case notFound = -5
    /** Resource busy */
    case resourceBusy = -6
    /** Operation timed out */
    case timeout = -7
    /** Overflow */
    case overflow = -8
    /** Pipe error */
    case pipe = -9
    /** System call interrupted (perhaps due to signal) */
    case syscallInterrupted = -10
    /** Insufficient memory */
    case insufficientMemory = -11
    /** Operation not supported or unimplemented on this platform */
    case notSupported = -12
    /** Other error */
    case unknown = -99
    
    case noAvailableDevice
    case alreadyOpen
}
