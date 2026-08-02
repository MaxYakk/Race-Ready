import Foundation

/// User's preferred unit system. Stored on `UserSettings` (rawValue persisted).
public enum UnitSystem: String, Codable, CaseIterable, Identifiable {
    case metric
    case imperial

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .metric: return "Metric (km · kg)"
        case .imperial: return "Imperial (mi · lb)"
        }
    }
}

/// Centralized formatter for converting canonical SI values into the user's chosen
/// display units, and parsing typed input back into SI.
///
/// All persisted data uses **meters · kg · seconds**. The formatter is a pure value type
/// constructed from the current `UnitSystem` and injected via `@Environment`.
public struct UnitFormatter: Equatable {
    public let system: UnitSystem

    public init(system: UnitSystem) {
        self.system = system
    }

    // MARK: - Distance

    /// Convert meters → display string with appropriate unit.
    /// - For runs we use km / mi.
    /// - For short station distances (<400 m) we use meters / feet.
    public func formatDistance(meters: Double, style: DistanceStyle = .auto) -> String {
        let useRunScale: Bool
        switch style {
        case .auto: useRunScale = meters >= 400
        case .runScale: useRunScale = true
        case .stationScale: useRunScale = false
        }

        if useRunScale {
            switch system {
            case .metric:
                let km = meters / 1_000
                return String(format: km == km.rounded() ? "%.0f km" : "%.2f km", km)
            case .imperial:
                let mi = meters / 1_609.344
                return String(format: "%.2f mi", mi)
            }
        } else {
            switch system {
            case .metric:
                return String(format: "%.0f m", meters)
            case .imperial:
                let ft = meters * 3.28084
                return String(format: "%.0f ft", ft)
            }
        }
    }

    public enum DistanceStyle {
        case auto, runScale, stationScale
    }

    // MARK: - Weight

    /// Convert kg → display string (kg or lb).
    public func formatWeight(kg: Double) -> String {
        switch system {
        case .metric:
            return String(format: kg == kg.rounded() ? "%.0f kg" : "%.1f kg", kg)
        case .imperial:
            let lb = kg * 2.20462262
            return String(format: lb == lb.rounded() ? "%.0f lb" : "%.1f lb", lb)
        }
    }

    // MARK: - Pace

    /// Format a pace given as **seconds per kilometer** in the user's chosen system.
    /// Returns e.g. "4:45/km" or "7:39/mi".
    public func formatPace(secondsPerKm: Int) -> String {
        switch system {
        case .metric:
            return formatMMSS(secondsPerKm) + "/km"
        case .imperial:
            // 1 mile = 1.609344 km, so pace/mi = pace/km × 1.609344
            let secondsPerMi = Int((Double(secondsPerKm) * 1.609344).rounded())
            return formatMMSS(secondsPerMi) + "/mi"
        }
    }

    /// Derive pace (seconds per km) from a logged run.
    public static func paceSecondsPerKm(distanceMeters: Double, durationSeconds: Int) -> Int? {
        guard distanceMeters > 0 else { return nil }
        return Int((Double(durationSeconds) / (distanceMeters / 1_000)).rounded())
    }

    // MARK: - Duration

    /// Format seconds as M:SS (under an hour) or H:MM:SS.
    public func formatDuration(seconds: Int) -> String {
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        let s = seconds % 60
        if h > 0 { return String(format: "%d:%02d:%02d", h, m, s) }
        return String(format: "%d:%02d", m, s)
    }

    private func formatMMSS(_ seconds: Int) -> String {
        String(format: "%d:%02d", seconds / 60, seconds % 60)
    }

    // MARK: - Parsing user run input

    /// Parse a typed distance into meters using the user's current system.
    /// Accepts plain numbers ("5", "5.0") or unit-suffixed ("5 mi", "8 km").
    public func parseDistance(_ input: String) -> Double? {
        let trimmed = input.trimmingCharacters(in: .whitespaces).lowercased()
        guard !trimmed.isEmpty else { return nil }

        if trimmed.hasSuffix("km") {
            return Double(trimmed.dropLast(2).trimmingCharacters(in: .whitespaces)).map { $0 * 1_000 }
        }
        if trimmed.hasSuffix("mi") || trimmed.hasSuffix("miles") {
            let stripped = trimmed
                .replacingOccurrences(of: "miles", with: "")
                .replacingOccurrences(of: "mi", with: "")
                .trimmingCharacters(in: .whitespaces)
            return Double(stripped).map { $0 * 1_609.344 }
        }
        if trimmed.hasSuffix("m") {
            return Double(trimmed.dropLast(1).trimmingCharacters(in: .whitespaces))
        }
        // No suffix — interpret in user's system.
        guard let value = Double(trimmed) else { return nil }
        switch system {
        case .metric: return value * 1_000   // assume km
        case .imperial: return value * 1_609.344  // assume mi
        }
    }

    /// Parse a duration like "40:00" or "1:25:30" into total seconds.
    public func parseDuration(_ input: String) -> Int? {
        let parts = input.split(separator: ":").compactMap { Int($0) }
        switch parts.count {
        case 1: return parts[0]                                           // seconds
        case 2: return parts[0] * 60 + parts[1]                           // m:ss
        case 3: return parts[0] * 3600 + parts[1] * 60 + parts[2]         // h:mm:ss
        default: return nil
        }
    }

    // MARK: - Placeholders

    public var distancePlaceholder: String {
        system == .metric ? "5.0 km" : "3.1 mi"
    }

    public var durationPlaceholder: String { "30:00" }
}
