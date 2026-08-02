import Foundation

/// A single line item inside an `ExerciseBlock`. Quantities are stored in
/// canonical SI units (kg for weight, meters for distance, seconds for time)
/// and rendered via `UnitFormatter` based on the user's chosen unit system.
public struct ExerciseItem: Codable, Hashable, Identifiable {
    public var id: String { name + (qualifier ?? "") }

    /// Display name, e.g. "Barbell bench press", "Wall ball", "1 km run".
    public let name: String

    public let sets: Int?
    public let reps: Int?
    public let repsLow: Int?   // For ranges like 6–10
    public let repsHigh: Int?

    /// Weight in kilograms. Source-of-truth metric value; UI converts to lb when imperial.
    public let weightKg: Double?

    /// Distance in meters. Source-of-truth metric value; UI converts to miles/feet when imperial.
    public let distanceMeters: Double?

    /// Duration in seconds (e.g. timed hold, EMOM round, rest interval).
    public let durationSeconds: Int?

    /// Rest between sets in seconds.
    public let restSeconds: Int?

    /// Free-form descriptor: "RPE 7–8", "/leg", "each side", "+2.5 lb/wk", etc.
    public let qualifier: String?

    /// Coaching cue from the PDF, e.g. "lats not arms", "hip drive, arm's length from wall".
    public let cue: String?

    public init(
        name: String,
        sets: Int? = nil,
        reps: Int? = nil,
        repsLow: Int? = nil,
        repsHigh: Int? = nil,
        weightKg: Double? = nil,
        distanceMeters: Double? = nil,
        durationSeconds: Int? = nil,
        restSeconds: Int? = nil,
        qualifier: String? = nil,
        cue: String? = nil
    ) {
        self.name = name
        self.sets = sets
        self.reps = reps
        self.repsLow = repsLow
        self.repsHigh = repsHigh
        self.weightKg = weightKg
        self.distanceMeters = distanceMeters
        self.durationSeconds = durationSeconds
        self.restSeconds = restSeconds
        self.qualifier = qualifier
        self.cue = cue
    }
}
