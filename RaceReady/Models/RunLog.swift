import Foundation
import SwiftData

/// Run-specific fields attached to a `SessionLog` of type `.easyRun` or `.thresholdRun`.
///
/// Canonical storage: **meters** for distance, **seconds** for duration. Pace is
/// derived at render time via `UnitFormatter.paceSecondsPerKm(distanceMeters:durationSeconds:)`.
@Model
public final class RunLog {
    public var distanceMeters: Double
    public var durationSeconds: Int

    /// 1 (none) … 5 (severe) — tracks how the lower legs felt during/after the run.
    public var legBurnRating: Int

    /// Free-form description of intervals actually performed, e.g. "6×1km @ 4:47 avg".
    public var intervalDescription: String

    @Relationship public var session: SessionLog?

    public init(
        distanceMeters: Double,
        durationSeconds: Int,
        legBurnRating: Int = 3,
        intervalDescription: String = ""
    ) {
        self.distanceMeters = distanceMeters
        self.durationSeconds = durationSeconds
        self.legBurnRating = legBurnRating
        self.intervalDescription = intervalDescription
    }

    /// Convenience: derived pace in seconds per kilometer (returns nil for zero distance).
    public var paceSecondsPerKm: Int? {
        UnitFormatter.paceSecondsPerKm(
            distanceMeters: distanceMeters,
            durationSeconds: durationSeconds
        )
    }
}
