import Foundation
import Combine

/// Drift-resilient session timer. Stores `startedAt: Date` and computes
/// elapsed time on every tick from `Date().timeIntervalSince(startedAt)` so
/// backgrounding the app doesn't lose time.
@MainActor
final class SessionTimer: ObservableObject {
    @Published private(set) var elapsedSeconds: Int = 0
    @Published private(set) var isRunning = false

    private var startedAt: Date?
    private var cancellable: AnyCancellable?

    func start() {
        startedAt = .now
        isRunning = true
        cancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in self?.tick() }
        tick()
    }

    func stop() {
        cancellable?.cancel()
        cancellable = nil
        isRunning = false
        tick() // capture final value
    }

    func reset() {
        cancellable?.cancel()
        cancellable = nil
        isRunning = false
        startedAt = nil
        elapsedSeconds = 0
    }

    private func tick() {
        guard let startedAt else { return }
        elapsedSeconds = Int(Date().timeIntervalSince(startedAt))
    }
}
