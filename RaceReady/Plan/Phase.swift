import Foundation

/// The four training phases. Boundaries are determined by **cumulative
/// completed sessions**, not calendar date — see `PlanEngine.phase(forCompletedSessions:)`.
public enum Phase: String, Codable, CaseIterable, Identifiable {
    case base       // Weeks 1–6
    case build      // Weeks 7–12
    case peak       // Weeks 13–17
    case taper      // Week 18

    public var id: String { rawValue }

    public var number: Int {
        switch self {
        case .base: return 1
        case .build: return 2
        case .peak: return 3
        case .taper: return 4
        }
    }

    public var title: String {
        switch self {
        case .base:  return "Base Build"
        case .build: return "Race-Specific Build"
        case .peak:  return "Peak & Simulation"
        case .taper: return "Taper"
        }
    }

    /// Inclusive week range covered by this phase in the canonical 18-week plan.
    public var weekRange: ClosedRange<Int> {
        switch self {
        case .base:  return 1...6
        case .build: return 7...12
        case .peak:  return 13...17
        case .taper: return 18...18
        }
    }

    /// Sessions per week prescribed by the PDF for this phase.
    public var sessionsPerWeek: Int {
        switch self {
        case .taper: return 3 // Mon easy + strides, Wed jog + race-pace strides, Thu race day
        default: return 6
        }
    }

    /// Cumulative session count at the END of this phase, used for phase detection.
    /// P1: 36, P2: 72, P3: 102, P4: 105.
    public var cumulativeSessionCount: Int {
        switch self {
        case .base:  return 6 * 6              // 36
        case .build: return 36 + 6 * 6         // 72
        case .peak:  return 72 + 5 * 6         // 102
        case .taper: return 102 + 3            // 105
        }
    }

    /// Target weekly run distance (meters) for the user's mileage progress bar.
    /// Phase mid-point of the PDF prescription.
    public var targetWeeklyRunMeters: Double {
        switch self {
        case .base:  return 20_000   // PDF Phase 1 builds 13→22 km, avg ~18 km
        case .build: return 30_000   // PDF Phase 2 builds 22→38 km, avg ~30 km
        case .peak:  return 28_000   // PDF Phase 3 holds 25–30 km with sim weeks heavier
        case .taper: return 8_000    // PDF Phase 4 (~50% cut)
        }
    }
}
