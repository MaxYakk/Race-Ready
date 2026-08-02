import SwiftUI

/// The six recurring session categories that make up the 18-week plan.
///
/// Drives icon, accent tint, and which Active Session subview is shown
/// (run-logging fields vs. lift reference vs. circuit checklist).
public enum SessionType: String, Codable, CaseIterable, Identifiable, Hashable {
    case pushDay
    case pullDay
    case legsDay
    case easyRun
    case thresholdRun
    case hyroxCircuit

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .pushDay: return "Push Day"
        case .pullDay: return "Pull Day"
        case .legsDay: return "Legs Day"
        case .easyRun: return "Easy Run"
        case .thresholdRun: return "Threshold Run"
        case .hyroxCircuit: return "Hyrox Circuit"
        }
    }

    /// SF Symbol name for use in lists, cards, and the tab bar.
    public var iconName: String {
        switch self {
        case .pushDay: return "figure.strengthtraining.traditional"
        case .pullDay: return "figure.strengthtraining.functional"
        case .legsDay: return "figure.cooldown"
        case .easyRun: return "figure.run"
        case .thresholdRun: return "stopwatch"
        case .hyroxCircuit: return "flame"
        }
    }

    /// Whether this session type captures run-specific data (distance, pace, leg-burn rating).
    public var isRun: Bool {
        self == .easyRun || self == .thresholdRun
    }

    /// Whether this session type is a strength/lift day.
    public var isLift: Bool {
        self == .pushDay || self == .pullDay || self == .legsDay
    }
}
