import CLibUSB

internal func getString(from index: UInt8, device: USBDevice) -> String? {
    guard let handle = device.libusbHandle else { return nil }
    let buffer = UnsafeMutablePointer<CChar>.allocate(capacity: 1024)
    
    libusb_get_string_descriptor_ascii(handle, index, buffer, 1024)
    
    return String(cString: buffer)
}
