#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

/// Byte counters of one connection, measured at the socket. Thread-safe;
/// updated from the network queue and readable from any thread.
public final class VNCConnectionStatistics: @unchecked Sendable {
    private let lock = NSLock()
    private var received: UInt64 = 0
    private var sent: UInt64 = 0

    public init() { }

    /// Bytes read from the server so far, including handshake and framebuffer data.
    public var bytesReceived: UInt64 {
        lock.lock(); defer { lock.unlock() }
        return received
    }

    /// Bytes written to the server so far, including input events.
    public var bytesSent: UInt64 {
        lock.lock(); defer { lock.unlock() }
        return sent
    }

    func addReceived(_ count: Int) {
        lock.lock(); defer { lock.unlock() }
        received &+= UInt64(max(0, count))
    }

    func addSent(_ count: Int) {
        lock.lock(); defer { lock.unlock() }
        sent &+= UInt64(max(0, count))
    }
}
