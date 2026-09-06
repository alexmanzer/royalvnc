#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

import Dispatch

/// Wraps a `NetworkConnection` and adds every byte that passes through the
/// two primitives to a `VNCConnectionStatistics` instance. All derived
/// reads and writes go through these primitives, so the counts are complete.
final class CountingNetworkConnection<Inner: NetworkConnection>: NetworkConnection {
    private let inner: Inner
    private let statistics: VNCConnectionStatistics

    init(inner: Inner, statistics: VNCConnectionStatistics) {
        self.inner = inner
        self.statistics = statistics
    }

    convenience init(settings: NetworkConnectionSettings) {
        self.init(inner: Inner(settings: settings), statistics: VNCConnectionStatistics())
    }

    var status: NetworkConnectionStatus { inner.status }
    var isReady: Bool { inner.isReady }

    func setStatusUpdateHandler(_ statusUpdateHandler: NetworkConnectionStatusUpdateHandler?) {
        inner.setStatusUpdateHandler(statusUpdateHandler)
    }

    func cancel() {
        inner.cancel()
    }

    func start(queue: DispatchQueue) {
        inner.start(queue: queue)
    }

    func read(minimumLength: Int, maximumLength: Int) async throws -> Data {
        let data = try await inner.read(minimumLength: minimumLength, maximumLength: maximumLength)
        statistics.addReceived(data.count)
        return data
    }

    func write(data: Data) async throws {
        try await inner.write(data: data)
        statistics.addSent(data.count)
    }
}
