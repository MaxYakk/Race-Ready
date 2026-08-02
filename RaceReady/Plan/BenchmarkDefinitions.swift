import Foundation

/// Catalogue of the benchmark tests the user logs every ~3 weeks.
/// Each `BenchmarkEntry` references one of these kinds.
public enum BenchmarkKind: String, Codable, CaseIterable, Identifiable {
    case fiveK
    case burpeeTest          // James Kelly EMOM 3min × 8 = 400m run + max burpees
    case quarterSim          // End of Wk 6
    case halfHyroxSim        // End of Wk 11
    case fullHyroxSim        // End of Wk 15

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .fiveK:         return "5K Time Trial"
        case .burpeeTest:    return "James Kelly Burpee Test"
        case .quarterSim:    return "Hyrox Quarter Sim"
        case .halfHyroxSim:  return "Half-Hyrox Sim"
        case .fullHyroxSim:  return "Full Hyrox Sim"
        }
    }

    /// Whether this benchmark records a time (seconds) or a count (reps).
    public var measuresTime: Bool {
        self != .burpeeTest
    }

    /// Target value to surface alongside the user's logged value.
    public var targetValue: Int {
        switch self {
        case .fiveK:         return 24 * 60          // ≤24:00 by end of Wk 6
        case .burpeeTest:    return 120              // 120+ beginner threshold
        case .quarterSim:    return 28 * 60          // <28:00
        case .halfHyroxSim:  return 40 * 60          // <40:00
        case .fullHyroxSim:  return 90 * 60          // 1:30:00
        }
    }

    public var targetCadenceWeeks: Int {
        switch self {
        case .burpeeTest: return 3
        default: return 0  // one-shot benchmarks at specific weeks
        }
    }

    public var notes: String {
        switch self {
        case .fiveK:
            return "Standalone time trial on hill loop or treadmill."
        case .burpeeTest:
            return "EMOM 3 min × 8 rounds = 400m run + max burpees in remaining time. Beginner 120, Intermediate 180, Elite 200+."
        case .quarterSim:
            return "4 × (1km run + 1 station). Stations: 1km row, 25 wall balls, 200m farmers, 50m sandbag lunges."
        case .halfHyroxSim:
            return "4 × (1km run + 1 station) at full race weights. Under 40:00 = on pace for 1:30."
        case .fullHyroxSim:
            return "Race-day order, race weights, race distance. Full dress rehearsal."
        }
    }
}
