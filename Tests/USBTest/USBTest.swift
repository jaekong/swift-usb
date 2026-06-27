import Testing
import BasicContainers
@testable import USB

@Test func `List all devices`() throws {
    let usb = try! USB()
    var devices = usb.getDevices()
    
    for i in devices.indices {
        try devices[i].open()
        print(devices[i].productName ?? "Unknown Name, Device PID: \(devices[i].productID)")
    }
}
