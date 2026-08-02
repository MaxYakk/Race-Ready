import SwiftUI
import SwiftData

@main
struct RaceReadyApp: App {

    let modelContainer: ModelContainer = {
        func build() throws -> ModelContainer {
            try ModelContainer(
                for: SessionLog.self, RunLog.self, BenchmarkEntry.self,
                QueueState.self, UserSettings.self,
                TemplateRecord.self, BlockRecord.self, ItemRecord.self,
                ActiveSessionState.self
            )
        }

        do {
            return try build()
        } catch {
            // Pre-release dev: when models change in an incompatible way the
            // existing store can't be opened. Nuke it and try once more so the
            // app boots into a fresh seeded state instead of crashing.
            // Remove this fallback once the schema stabilizes for v1 release.
            let appSupport = try? FileManager.default.url(
                for: .applicationSupportDirectory, in: .userDomainMask,
                appropriateFor: nil, create: false
            )
            if let appSupport {
                let candidates = [
                    appSupport.appendingPathComponent("default.store"),
                    appSupport.appendingPathComponent("default.store-shm"),
                    appSupport.appendingPathComponent("default.store-wal")
                ]
                for url in candidates {
                    try? FileManager.default.removeItem(at: url)
                }
            }
            if let container = try? build() {
                return container
            }
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .preferredColorScheme(.dark)
                .tint(Theme.accent)
        }
        .modelContainer(modelContainer)
    }
}
