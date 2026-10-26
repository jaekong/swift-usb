import CLibUSB

extension USBDevice {
    public func bulkTransfer(
        _ data: inout MutableRawSpan,
        to endpoint: USBEndpoint,
        timeout: UInt32 = 1000
    ) throws(USBError) {
        let size = data.byteCount
        try data.withUnsafeMutableBytes { (dataBuffer: UnsafeMutableRawBufferPointer) throws(USBError) in
            let code = libusb_bulk_transfer(
                self.libusbHandle,
                endpoint.address,
                dataBuffer.baseAddress,
                Int32(size),
                nil, timeout
            )
            
            if let status = USBError(rawValue: code) {
                throw status
            }
        }
    }
    
    @concurrent
    public func bulkTransfer(
        _ data: inout MutableRawSpan,
        to endpoint: USBEndpoint,
        timeout: UInt32 = 1000
    ) async throws(USBError) {
        typealias TransferContinuation = UnsafeContinuation<Void, USBError>
        
        let size = data.byteCount
        
        try await withUnsafeThrowingContinuation { (continuation: TransferContinuation) in
            data.withUnsafeMutableBytes { dataBuffer in
                let code = libusb_bulk_transfer(
                    self.libusbHandle,
                    endpoint.address,
                    dataBuffer.baseAddress,
                    Int32(size),
                    nil, timeout
                )
                
                if let status = USBError(rawValue: code) {
                    continuation.resume(throwing: status)
                } else {
                    continuation.resume()
                }
            }
        }
    }
    
    public func bulkTransfer(
        _ data: borrowing RawSpan,
        to endpoint: USBEndpoint,
        callback: (@convention(c) (UnsafeMutablePointer<libusb_transfer>?) -> Void)? = nil,
        timeout: UInt32 = 1000
    ) throws(USBError) {
        let size = data.byteCount
        try data.withUnsafeBytes { (dataBuffer: UnsafeRawBufferPointer) throws(USBError) in
            let bufferBasePointer = dataBuffer.baseAddress!
            let opaquePointer = OpaquePointer(bufferBasePointer)
            let mutablePointer = UnsafeMutablePointer<UInt8>(opaquePointer)
            
            let code = libusb_bulk_transfer(
                self.libusbHandle,
                endpoint.address,
                mutablePointer,
                Int32(size),
                nil, timeout
            )
            
            if let status = USBError(rawValue: code) {
                throw status
            }
        }
    }
    
    @concurrent
    public func bulkTransfer(
        _ data: borrowing RawSpan,
        to endpoint: USBEndpoint,
        timeout: UInt32 = 1000
    ) async throws(USBError) {
        typealias TransferContinuation = UnsafeContinuation<Void, USBError>
        
        let size = data.byteCount

        try await withUnsafeThrowingContinuation { (continuation: TransferContinuation) in
            data.withUnsafeBytes { dataBuffer in
                let bufferBasePointer = dataBuffer.baseAddress!
                let opaquePointer = OpaquePointer(bufferBasePointer)
                let mutablePointer = UnsafeMutablePointer<UInt8>(opaquePointer)
                
                let code = libusb_bulk_transfer(
                    self.libusbHandle,
                    endpoint.address,
                    mutablePointer,
                    Int32(size),
                    nil, timeout
                )
                
                if let status = USBError(rawValue: code) {
                    continuation.resume(throwing: status)
                } else {
                    continuation.resume()
                }
            }
        }
    }
    
    public func bulkTransfer(
        _ bytes: [UInt8],
        to endpoint: USBEndpoint,
        callback: (@convention(c) (UnsafeMutablePointer<libusb_transfer>?) -> Void)? = nil,
        timeout: UInt32 = 1000
    ) throws(USBError) {
        try bulkTransfer(
            bytes.span.bytes,
            to: endpoint,
            callback: callback,
            timeout: timeout
        )
    }
    
    public func bulkTransfer<let count: Int>(
        _ bytes: [count of UInt8],
        to endpoint: USBEndpoint,
        callback: (@convention(c) (UnsafeMutablePointer<libusb_transfer>?) -> Void)? = nil,
        timeout: UInt32 = 1000
    ) throws(USBError) {
        try bulkTransfer(
            bytes.span.bytes,
            to: endpoint,
            callback: callback,
            timeout: timeout
        )
    }
    
    public func bulkTransfer(
        _ bytes: Span<UInt8>,
        to endpoint: USBEndpoint,
        callback: (@convention(c) (UnsafeMutablePointer<libusb_transfer>?) -> Void)? = nil,
        timeout: UInt32 = 1000
    ) throws(USBError) {
        try bulkTransfer(
            bytes.bytes,
            to: endpoint,
            callback: callback,
            timeout: timeout
        )
    }
    
    @concurrent
    public func bulkTransfer(
        _ bytes: [UInt8],
        to endpoint: USBEndpoint,
        timeout: UInt32 = 1000
    ) async throws(USBError) {
        try await bulkTransfer(bytes.span.bytes, to: endpoint, timeout: timeout)
    }
    
    @concurrent
    public func bulkTransfer<let count: Int>(
        _ bytes: [count of UInt8],
        to endpoint: USBEndpoint,
        timeout: UInt32 = 1000
    ) async throws(USBError) {
        try await bulkTransfer(bytes.span.bytes, to: endpoint, timeout: timeout)
    }
    
    @concurrent
    public func bulkTransfer(
        _ bytes: Span<UInt8>,
        to endpoint: USBEndpoint,
        timeout: UInt32 = 1000
    ) async throws(USBError) {
        try await bulkTransfer(bytes.bytes, to: endpoint, timeout: timeout)
    }
}
