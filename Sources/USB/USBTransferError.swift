import CLibUSB

enum USBTransferError: UInt32, Error {
    case fail = 1
    case timeout = 2
    case cancelled = 3
    case disconnected = 5
    case overflow = 6
}

/*
enum libusb_transfer_status {
    /** Transfer completed without error. Note that this does not indicate
     * that the entire amount of requested data was transferred. */
    LIBUSB_TRANSFER_COMPLETED,

    /** Transfer failed */
    LIBUSB_TRANSFER_ERROR,

    /** Transfer timed out */
    LIBUSB_TRANSFER_TIMED_OUT,

    /** Transfer was cancelled */
    LIBUSB_TRANSFER_CANCELLED,

    /** For bulk/interrupt endpoints: halt condition detected (endpoint
     * stalled). For control endpoints: control request not supported. */
    LIBUSB_TRANSFER_STALL,

    /** Device was disconnected */
    LIBUSB_TRANSFER_NO_DEVICE,

    /** Device sent more data than requested */
    LIBUSB_TRANSFER_OVERFLOW

    /* NB! Remember to update libusb_error_name()
       when adding new status codes here. */
};
*/
