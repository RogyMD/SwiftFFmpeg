//
//  AVBuffer.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2018/7/24.
//

import CFFmpeg

typealias CAVBuffer = CFFmpeg.AVBufferRef

public final class AVBuffer {
    var cBufferPtr: UnsafeMutablePointer<CAVBuffer>?
    var cBuffer: CAVBuffer {
        precondition(cBufferPtr != nil, "buffer has been freed")
        return cBufferPtr!.pointee
    }

    init(cBufferPtr: UnsafeMutablePointer<CAVBuffer>) {
        self.cBufferPtr = cBufferPtr
    }

    /// Create an `AVBuffer` of the given size. (for test)
    ///
    /// - Parameter size: size of the buffer
    convenience init(size: Int) {
        guard let bufPtr = av_buffer_alloc(Int32(size)) else {
            fatalError("av_buffer_alloc")
        }
        self.init(cBufferPtr: bufPtr)
    }

    /// The data buffer.
    public var data: UnsafeMutablePointer<UInt8> {
        return cBuffer.data
    }

    /// Size of data in bytes.
    public var size: Int {
        return Int(cBuffer.size)
    }

    public var refCount: Int {
        precondition(cBufferPtr != nil, "buffer has been freed")
        return Int(av_buffer_get_ref_count(cBufferPtr))
    }

    /// Reallocate a given buffer.
    ///
    /// - Parameter size: required new buffer size
    public func realloc(size: Int) {
        precondition(cBufferPtr != nil, "buffer has been freed")
        abortIfFail(av_buffer_realloc(&cBufferPtr, Int32(size)))
    }

    /// Check if the buffer is writable.
    ///
    /// - Returns: True if and only if this is the only reference to the underlying buffer.
    public func isWritable() -> Bool {
        precondition(cBufferPtr != nil, "buffer has been freed")
        return av_buffer_is_writable(cBufferPtr) > 0
    }

    /// Create a writable reference from a given buffer reference, avoiding data copy if possible.
    ///
    /// Do nothing if the frame is writable, allocate new buffers and copy the data if it is not.
    public func makeWritable() {
        precondition(cBufferPtr != nil, "buffer has been freed")
        abortIfFail(av_buffer_make_writable(&cBufferPtr))
    }

    /// Create a new reference to an `AVBuffer`.
    ///
    /// - Returns: a new `AVBuffer` referring to the same underlying buffer or `nil` on failure.
    public func ref() -> AVBuffer? {
        precondition(cBufferPtr != nil, "buffer has been freed")
        return AVBuffer(cBufferPtr: av_buffer_ref(cBufferPtr))
    }

    /// Free a given reference and automatically free the buffer if there are no more references to it.
    public func unref() {
        av_buffer_unref(&cBufferPtr)
    }
}
