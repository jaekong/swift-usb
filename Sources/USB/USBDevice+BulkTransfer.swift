import CLibUSB

extension USBDevice {
    public func bulkTransfer(
        _ data: inout MutableRawSpan,
        to endpoint: USBEndpoint,
        callback: (@convention(c) (UnsafeMutablePointer<libusb_transfer>?) -> Void)? = nil,
        timeout: UInt32 = 1000
    ) {
        let size = data.byteCount
        data.withUnsafeMutableBytes { dataBuffer in
            let transfer = libusb_alloc_transfer(0)
            
            libusb_fill_bulk_transfer(
                transfer,
                self.libusbHandle,
                endpoint.address,
                dataBuffer.baseAddress,
                Int32(size),
                callback, nil, timeout
            )
            
            libusb_submit_transfer(transfer)
        }
    }
    
    @concurrent
    public func bulkTransfer(
        _ data: inout MutableRawSpan,
        to endpoint: USBEndpoint,
        timeout: UInt32 = 1000
    ) async throws(USBTransferError) {
        typealias TransferContinuation = UnsafeContinuation<Void, USBTransferError>
        
        let size = data.byteCount
        
        try await withUnsafeThrowingContinuation { (continuation: TransferContinuation) in
            var continuationCopy = continuation
            
            data.withUnsafeMutableBytes { dataBuffer in
                let transfer = libusb_alloc_transfer(0)
                
                libusb_fill_bulk_transfer(
                    transfer,
                    self.libusbHandle,
                    endpoint.address,
                    dataBuffer.baseAddress,
                    Int32(size),
                    { transferPointer in
                        guard let transfer = transferPointer?.pointee else {
                            fatalError("Received Null/Invalid Transfer Object.")
                        }
                        
                        let continuation = transfer.user_data
                            .assumingMemoryBound(
                                to: UnsafePointer<TransferContinuation>.self
                            )
                            .pointee
                            .pointee
                        
                        let status = transfer.status
                        
                        guard status.rawValue == 0 else {
                            guard let error = USBTransferError(rawValue: status.rawValue) else {
                                continuation.resume()
                                fatalError("Unknown libusb Transfer Status: \(status).")
                            }
                            continuation.resume(throwing: error)
                            return
                        }
                        
                        continuation.resume()
                    }, &continuationCopy, timeout
                )
                
                libusb_submit_transfer(transfer)
            }
        }
    }
    
    public func bulkTransfer(
        _ data: borrowing RawSpan,
        to endpoint: USBEndpoint,
        callback: (@convention(c) (UnsafeMutablePointer<libusb_transfer>?) -> Void)? = nil,
        timeout: UInt32 = 1000
    ) {
        let size = data.byteCount
        data.withUnsafeBytes { dataBuffer in
            let bufferBasePointer = dataBuffer.baseAddress!
            let opaquePointer = OpaquePointer(bufferBasePointer)
            let mutablePointer = UnsafeMutablePointer<UInt8>(opaquePointer)
            let transfer = libusb_alloc_transfer(0)
            
            libusb_fill_bulk_transfer(
                transfer,
                self.libusbHandle,
                endpoint.address,
                mutablePointer,
                Int32(size),
                callback, nil, timeout
            )
            
            libusb_submit_transfer(transfer)
        }
    }
    
    @concurrent
    public func bulkTransfer(
        _ data: borrowing RawSpan,
        to endpoint: USBEndpoint,
        timeout: UInt32 = 1000
    ) async throws(USBTransferError) {
        typealias TransferContinuation = UnsafeContinuation<Void, USBTransferError>
        
        let size = data.byteCount

        try await withUnsafeThrowingContinuation { (continuation: TransferContinuation) in
            data.withUnsafeBytes { dataBuffer in
                let bufferBasePointer = dataBuffer.baseAddress!
                let opaquePointer = OpaquePointer(bufferBasePointer)
                let mutablePointer = UnsafeMutablePointer<UInt8>(opaquePointer)
                
                let transfer = libusb_alloc_transfer(0)
                
                var continuationCopy = continuation
                
                libusb_fill_bulk_transfer(
                    transfer,
                    self.libusbHandle,
                    endpoint.address,
                    mutablePointer,
                    Int32(size),
                    { transferPointer in
                        guard let transfer = transferPointer?.pointee else {
                            fatalError("Received Null/Invalid Transfer Object.")
                        }
                        
                        let continuation = transfer.user_data
                            .assumingMemoryBound(
                                to: UnsafePointer<TransferContinuation>.self
                            )
                            .pointee
                            .pointee
                        
                        let status = transfer.status
                        
                        guard status.rawValue == 0 else {
                            guard let error = USBTransferError(rawValue: status.rawValue) else {
                                continuation.resume()
                                fatalError("Unknown libusb Transfer Status: \(status).")
                            }
                            continuation.resume(throwing: error)
                            return
                        }
                        
                        continuation.resume()
                    }, &continuationCopy, timeout
                )
                
                libusb_submit_transfer(transfer)
            }
        }
    }
    
    public func bulkTransfer(
        _ bytes: [UInt8],
        to endpoint: USBEndpoint,
        callback: (@convention(c) (UnsafeMutablePointer<libusb_transfer>?) -> Void)? = nil,
        timeout: UInt32 = 1000
    ) {
        bulkTransfer(
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
    ) {
        bulkTransfer(
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
    ) {
        bulkTransfer(
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
    ) async throws(USBTransferError) {
        try await bulkTransfer(bytes.span.bytes, to: endpoint, timeout: timeout)
    }
    
    @concurrent
    public func bulkTransfer<let count: Int>(
        _ bytes: [count of UInt8],
        to endpoint: USBEndpoint,
        timeout: UInt32 = 1000
    ) async throws(USBTransferError) {
        try await bulkTransfer(bytes.span.bytes, to: endpoint, timeout: timeout)
    }
    
    @concurrent
    public func bulkTransfer(
        _ bytes: Span<UInt8>,
        to endpoint: USBEndpoint,
        timeout: UInt32 = 1000
    ) async throws(USBTransferError) {
        try await bulkTransfer(bytes.bytes, to: endpoint, timeout: timeout)
    }
}
