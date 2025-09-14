import Foundation
import CLibUSB

public enum USBDeviceClass: UInt8 {
    case perInterface = 0x00
    case audioDevice = 0x01
    case communications = 0x02
    case hid = 0x03
    case physical = 0x05
    case image = 0x06
    case printer = 0x07
    case massStorage = 0x08
    case hub = 0x09
    case data = 0x0A
    case smartCard = 0x0B
    case contentSecurity = 0x0D
    case video = 0x0E
    case personalHealthcare = 0x0F
    case diagnosticDevice = 0xDC
    case wireless = 0xE0
    case miscellaneous = 0xEF
    case application = 0xFE
    case vendorSpecific = 0xFF
}
