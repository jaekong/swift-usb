import CLibUSB

internal func getString(from index: UInt8, deviceHandle: OpaquePointer, maxLength: Int32 = 1024) -> String? {
    let buffer = UnsafeMutablePointer<CChar>.allocate(capacity: Int(maxLength))
    libusb_get_string_descriptor_ascii(deviceHandle, index, buffer, maxLength)
    return String(cString: buffer)
}
