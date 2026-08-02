import Foundation

/// Structured description of a run interval prescription so the Active Session
/// view can render targets and the user can log against them.
///
/// Example: `6 × 1km @ 4:45, 90s rest` →
/// `IntervalPrescription(reps: 6, repDistanceMeters: 1000, repTargetPaceSecondsPerKm: 285, restSeconds: 90)`
public struct IntervalPrescription: Codable, Hashable {
    /// Number of work intervals.
    public let reps: Int

    /// Distance of each work interval in meters.
    public let repDistanceMeters: Double?

    /// Duration of each work interval in seconds (when prescribed by time, not distance).
    public let repDurationSeconds: Int?

    /// Target pace per kilometer, seconds. Display converts to /mi when imperial.
    public let repTargetPaceSecondsPerKm: Int?

    /// Rest between intervals in seconds.
    public let restSeconds: Int

    /// Human-readable original phrasing from the plan (fallback for edge cases).
    public let description: String

    public init(
        reps: Int,
        repDistanceMeters: Double? = nil,
        repDurationSeconds: Int? = nil,
        repTargetPaceSecondsPerKm: Int? = nil,
        restSeconds: Int,
        description: String
    ) {
        self.reps = reps
        self.repDistanceMeters = repDistanceMeters
        self.repDurationSeconds = repDurationSeconds
        self.repTargetPaceSecondsPerKm = repTargetPaceSecondsPerKm
        self.restSeconds = restSeconds
        self.description = description
    }
}
