#if !hasFeature(Embedded) && (canImport(Foundation) || canImport(FoundationEssentials))
import CLibUSB

#if canImport(FoundationEssentials)
import FoundationEssentials
#elseif canImport(Foundation)
import Foundation
#endif

extension USBDevice {
    public func bulkTransfer(
        _ bytes: some ContiguousBytes,
        to endpoint: USBEndpoint,
        callback: (@convention(c) (UnsafeMutablePointer<libusb_transfer>?) -> Void)? = nil,
        timeout: UInt32 = 1000
    ) {
        bytes.withBytes { span in
            bulkTransfer(
                span,
                to: endpoint,
                callback: callback,
                timeout: timeout
            )
        }
    }
    
    public func bulkTransfer(
        _ data: Data,
        to endpoint: USBEndpoint,
        timeout: UInt32 = 1000
    ) async throws {
        try await bulkTransfer(data.bytes, to: endpoint, timeout: timeout)
    }
}

#endif
