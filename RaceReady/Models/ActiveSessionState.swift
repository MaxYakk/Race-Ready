import Foundation
import SwiftData

/// Persisted, singleton-by-convention record of an in-progress session.
/// Stored so the timer, completed-exercise checkmarks, and run-log fields
/// survive the user backgrounding or quitting the app mid-workout.
///
/// Lifecycle:
/// - Created when the user taps "Start" on the Dashboard.
/// - Mutated as the user checks off exercises and edits in-progress fields.
/// - Deleted when the user taps Complete (after writing the SessionLog) or Abandon.
@Model
public final class ActiveSessionState {
    /// `SessionTemplate.id` / `TemplateRecord.id` of the workout in progress.
    public var templateId: String

    /// Wall-clock instant the user tapped Start. Elapsed time is derived from
    /// `Date().timeIntervalSince(startedAt)` so backgrounding doesn't drift.
    public var startedAt: Date

    /// Stable ids (UUID.uuidString) of every `ItemRecord` the user has marked
    /// complete in the walkthrough. Set semantics — order doesn't matter.
    public var completedItemIds: [String]

    // MARK: - In-progress run fields (only meaningful for run sessions)

    public var distanceText: String
    public var durationText: String
    public var legBurnRating: Int
    public var intervalDescription: String

    /// Free-form notes typed during the session.
    public var notes: String

    public init(
        templateId: String,
        startedAt: Date = .now,
        completedItemIds: [String] = [],
        distanceText: String = "",
        durationText: String = "",
        legBurnRating: Int = 3,
        intervalDescription: String = "",
        notes: String = ""
    ) {
        self.templateId = templateId
        self.startedAt = startedAt
        self.completedItemIds = completedItemIds
        self.distanceText = distanceText
        self.durationText = durationText
        self.legBurnRating = legBurnRating
        self.intervalDescription = intervalDescription
        self.notes = notes
    }
}
