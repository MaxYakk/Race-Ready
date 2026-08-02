import Foundation
import SwiftData

/// Singleton-by-convention model holding the user's persisted session queue.
///
/// There should only ever be ONE `QueueState` in the store. `QueueService`
/// fetches it on demand and creates one on first launch by seeding from
/// `PlanData.allTemplates` in default order.
@Model
public final class QueueState {
    /// Ordered list of upcoming `SessionTemplate.id`s. Head = next session.
    public var orderedTemplateIds: [String]

    /// Templates the user explicitly Dropped (won't be re-served, affects phase math).
    public var droppedTemplateIds: [String]

    /// When the queue was last (re)built — used for diagnostics only.
    public var lastBuiltAt: Date

    public init(
        orderedTemplateIds: [String] = [],
        droppedTemplateIds: [String] = [],
        lastBuiltAt: Date = .now
    ) {
        self.orderedTemplateIds = orderedTemplateIds
        self.droppedTemplateIds = droppedTemplateIds
        self.lastBuiltAt = lastBuiltAt
    }
}
