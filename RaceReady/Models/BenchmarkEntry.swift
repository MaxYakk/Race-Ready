import Foundation
import SwiftData

/// User-logged benchmark measurement (5K time, burpee test, full sim, etc.).
/// Multiple entries per kind over time → Analytics trend charts.
@Model
public final class BenchmarkEntry {
    public var date: Date
    public var kindRaw: String

    /// Value in seconds (for time-based benchmarks). Nil for count-based.
    public var valueSeconds: Int?

    /// Value as count (for `.burpeeTest`). Nil for time-based.
    public var valueCount: Int?

    public var notes: String

    public init(
        date: Date,
        kind: BenchmarkKind,
        valueSeconds: Int? = nil,
        valueCount: Int? = nil,
        notes: String = ""
    ) {
        self.date = date
        self.kindRaw = kind.rawValue
        self.valueSeconds = valueSeconds
        self.valueCount = valueCount
        self.notes = notes
    }

    public var kind: BenchmarkKind {
        BenchmarkKind(rawValue: kindRaw) ?? .fiveK
    }

    /// Returns the display string for this entry.
    public func formattedValue(using formatter: UnitFormatter) -> String {
        if kind.measuresTime, let secs = valueSeconds {
            return formatter.formatDuration(seconds: secs)
        }
        if let count = valueCount {
            return "\(count) reps"
        }
        return "—"
    }
}
