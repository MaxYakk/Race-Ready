import Foundation

/// The complete 18-week Hyrox plan, transcribed from the PDF and exposed as
/// strongly-typed Swift data. Split across `PlanData+Phase*.swift` extensions.
///
/// Conventions:
/// - Templates ordered Mon → Sat within each week (slot 0…5), or Mon/Wed/Thu for Phase 4 (slot 0…2).
/// - All weights stored in **kg**, distances in **meters**, durations in **seconds**.
/// - `id` format: `"wk{ww}-{type}-{slot}"`, e.g. `"wk03-pushDay-0"`.
public enum PlanData {

    /// The single source of truth — concatenation of all phase templates in week order.
    public static let allTemplates: [SessionTemplate] = {
        var out: [SessionTemplate] = []
        out.append(contentsOf: phase1Templates)
        out.append(contentsOf: phase2Templates)
        out.append(contentsOf: phase3Templates)
        out.append(contentsOf: phase4Templates)
        return out
    }()

    /// Templates indexed by id for fast lookup from queue state.
    public static let byId: [String: SessionTemplate] = {
        Dictionary(uniqueKeysWithValues: allTemplates.map { ($0.id, $0) })
    }()

    /// Templates filtered by week.
    public static func templates(forWeek week: Int) -> [SessionTemplate] {
        allTemplates.filter { $0.weekNumber == week }.sorted { $0.slot < $1.slot }
    }

    /// Templates filtered by phase.
    public static func templates(in phase: Phase) -> [SessionTemplate] {
        allTemplates.filter { phase.weekRange.contains($0.weekNumber) }
    }

    // MARK: - ID helper

    public static func id(week: Int, type: SessionType, slot: Int) -> String {
        String(format: "wk%02d-%@-%d", week, type.rawValue, slot)
    }
}

// MARK: - Shared building blocks reused across many sessions

extension PlanData {

    /// "Lower-leg finisher" used across most lift days in Phase 1–2.
    static let lowerLegFinisher = ExerciseBlock(
        title: "Lower-leg finisher",
        items: [
            ExerciseItem(name: "Tibialis raises", sets: 3, reps: 20),
            ExerciseItem(name: "Single-leg calf raises off step", sets: 3, reps: 15, qualifier: "each leg"),
            ExerciseItem(name: "Single-leg balance", sets: 3, durationSeconds: 60, qualifier: "each leg")
        ]
    )

    /// Push Day main lifts (Phase 1 prescription — Phase 2/3 adjust sets/reps).
    static func pushMain(setsTopRange: Int = 4, repRange: ClosedRange<Int> = 6...10) -> ExerciseBlock {
        ExerciseBlock(
            title: "Push — main lifts",
            subtitle: "60 min",
            items: [
                ExerciseItem(name: "Barbell bench press", sets: setsTopRange, repsLow: repRange.lowerBound, repsHigh: repRange.upperBound, qualifier: "RPE 7–8, +2.5–5 lb/wk"),
                ExerciseItem(name: "Incline DB press", sets: 3, repsLow: 8, repsHigh: 12),
                ExerciseItem(name: "Cable lateral raise", sets: 3, repsLow: 12, repsHigh: 15),
                ExerciseItem(name: "Single-arm tricep pulldown SS rear-delt pulldown", sets: 3, reps: 12, qualifier: "each side"),
                ExerciseItem(name: "Dips", sets: 3, repsLow: 8, repsHigh: 12, qualifier: "weighted if RPE < 7")
            ]
        )
    }

    /// Pull Day main lifts (Phase 1).
    static let pullMainPhase1 = ExerciseBlock(
        title: "Pull — main lifts",
        subtitle: "60 min",
        items: [
            ExerciseItem(name: "Lat pulldown", sets: 4, repsLow: 8, repsHigh: 12),
            ExerciseItem(name: "T-bar row", sets: 4, repsLow: 8, repsHigh: 10, qualifier: "sled-pull insurance — push the weight"),
            ExerciseItem(name: "Lat pullover", sets: 3, reps: 12),
            ExerciseItem(name: "Incline DB curl", sets: 3, reps: 10),
            ExerciseItem(name: "Machine hammer curl", sets: 3, reps: 12)
        ]
    )

    /// Grip + row finisher used on Pull days.
    static let pullFinisher = ExerciseBlock(
        title: "Grip + row finisher",
        items: [
            ExerciseItem(name: "Farmer's hold", sets: 4, weightKg: 24,
                         durationSeconds: 30, qualifier: "heaviest DBs (proxy for 24 kg race carry)"),
            ExerciseItem(name: "Row 500 m", sets: 1, distanceMeters: 500,
                         cue: "Moderate pace ~2:00/500m — learn the stroke.")
        ]
    )

    static let pullFinisherPhase2 = ExerciseBlock(
        title: "Grip finisher",
        items: [
            ExerciseItem(name: "Farmer's hold", sets: 4, weightKg: 24, durationSeconds: 30, qualifier: "race-carry weight")
        ]
    )
}
