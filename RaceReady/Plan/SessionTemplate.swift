import Foundation

/// A static, queue-eligible session blueprint. One template per session in the
/// 18-week plan (~105 total). The template defines what to do; a `SessionLog`
/// records that the user actually did it.
public struct SessionTemplate: Codable, Hashable, Identifiable {
    /// Stable identifier: "wk{week}-{type}-{slot}", e.g. "wk03-pushDay-0".
    public let id: String

    public let weekNumber: Int

    public let sessionType: SessionType

    /// Position within the week (0-indexed), used to keep the default queue
    /// in the same Mon→Sun order as the PDF prescribes.
    public let slot: Int

    /// Short title for cards, e.g. "Push + Skill A", "Easy Run · Week 3".
    public let title: String

    /// Coaching subtitle, e.g. "Aerobic base — Z2 talk-test pace".
    public let subtitle: String?

    /// Estimated duration in seconds (used for Up Next card and analytics).
    public let estimatedDurationSeconds: Int

    /// Structured run prescription, if this is a run session.
    public let intervalPrescription: IntervalPrescription?

    /// Target total run distance for this session in meters (long runs, easy runs).
    public let targetRunDistanceMeters: Double?

    /// Exercise content, organized into named blocks.
    public let blocks: [ExerciseBlock]

    /// Free-form coaching notes (PDF prose preserved here).
    public let notes: [String]

    public init(
        id: String,
        weekNumber: Int,
        sessionType: SessionType,
        slot: Int,
        title: String,
        subtitle: String? = nil,
        estimatedDurationSeconds: Int,
        intervalPrescription: IntervalPrescription? = nil,
        targetRunDistanceMeters: Double? = nil,
        blocks: [ExerciseBlock] = [],
        notes: [String] = []
    ) {
        self.id = id
        self.weekNumber = weekNumber
        self.sessionType = sessionType
        self.slot = slot
        self.title = title
        self.subtitle = subtitle
        self.estimatedDurationSeconds = estimatedDurationSeconds
        self.intervalPrescription = intervalPrescription
        self.targetRunDistanceMeters = targetRunDistanceMeters
        self.blocks = blocks
        self.notes = notes
    }
}

public extension SessionTemplate {
    /// Convenience: which phase this template belongs to based on its week number.
    var phase: Phase {
        Phase.allCases.first { $0.weekRange.contains(weekNumber) } ?? .base
    }
}
