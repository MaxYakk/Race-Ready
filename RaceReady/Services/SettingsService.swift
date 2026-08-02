import Foundation
import SwiftData

/// Convenience accessor for the singleton `UserSettings`. Creates one on first use.
public struct SettingsService {
    public let context: ModelContext

    public init(context: ModelContext) {
        self.context = context
    }

    public func fetchOrCreate() -> UserSettings {
        let descriptor = FetchDescriptor<UserSettings>()
        if let existing = (try? context.fetch(descriptor))?.first {
            return existing
        }
        let new = UserSettings()
        context.insert(new)
        return new
    }
}
