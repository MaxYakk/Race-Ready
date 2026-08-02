import Foundation
import SwiftData

/// Computes derived analytics from persisted `SessionLog` / `RunLog` data.
/// Pure read-only — no mutations. Constructed per-render via the SwiftUI
/// `@Query` results so charts and PRs stay live.
public struct AnalyticsService {

    public let logs: [SessionLog]
    public let runs: [RunLog]
    public let benchmarks: [BenchmarkEntry]

    public init(logs: [SessionLog], runs: [RunLog], benchmarks: [BenchmarkEntry]) {
        self.logs = logs
        self.runs = runs
        self.benchmarks = benchmarks
    }

    // MARK: - Weekly mileage

    /// Returns weekly run distance in meters, keyed by (year, weekOfYear).
    public func weeklyRunMeters(calendar: Calendar = .current) -> [(weekStart: Date, meters: Double)] {
        let grouped = Dictionary(grouping: runs) { run -> Date in
            startOfWeek(for: run.session?.date ?? .now, calendar: calendar)
        }
        return grouped
            .map { (start, runs) in (start, runs.reduce(0) { $0 + $1.distanceMeters }) }
            .sorted { $0.weekStart < $1.weekStart }
    }

    /// Current-week run total in meters.
    public func currentWeekRunMeters(asOf now: Date = .now,
                                     calendar: Calendar = .current) -> Double {
        let weekStart = startOfWeek(for: now, calendar: calendar)
        return runs
            .filter { ($0.session?.date ?? .distantPast) >= weekStart }
            .reduce(0) { $0 + $1.distanceMeters }
    }

    private func startOfWeek(for date: Date, calendar: Calendar) -> Date {
        var cal = calendar
        cal.firstWeekday = 2 // Monday — matches the PDF's Mon-anchored weekly templates
        let comps = cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return cal.date(from: comps) ?? date
    }

    // MARK: - Personal records

    /// Fastest pace ever recorded (seconds per km). Nil if no runs.
    public var fastestPaceSecondsPerKm: Int? {
        runs
            .compactMap(\.paceSecondsPerKm)
            .min()
    }

    /// Longest run distance (meters).
    public var longestRunMeters: Double? {
        runs.map(\.distanceMeters).max()
    }

    /// Current consecutive-day session streak ending today (or yesterday).
    /// A "streak day" is any day with at least one `SessionLog`.
    public func currentStreak(asOf now: Date = .now,
                              calendar: Calendar = .current) -> Int {
        let days = Set(logs.map { calendar.startOfDay(for: $0.date) })
        var streak = 0
        var day = calendar.startOfDay(for: now)
        // Allow today to be unrecorded — start from yesterday if today missing.
        if !days.contains(day) {
            day = calendar.date(byAdding: .day, value: -1, to: day) ?? day
        }
        while days.contains(day) {
            streak += 1
            day = calendar.date(byAdding: .day, value: -1, to: day) ?? day
        }
        return streak
    }

    // MARK: - Phase progress

    /// Sessions completed in the current phase / total in phase.
    public func phaseProgress(currentPhase: Phase) -> (completed: Int, total: Int) {
        let completed = logs.filter { $0.phase == currentPhase }.count
        return (completed, PlanEngine.totalSessions(in: currentPhase))
    }

    // MARK: - Leg-burn trend

    /// Average leg-burn rating per week, sorted oldest-to-newest.
    public func legBurnTrend(calendar: Calendar = .current)
        -> [(weekStart: Date, averageBurn: Double)] {
        let grouped = Dictionary(grouping: runs) { run -> Date in
            startOfWeek(for: run.session?.date ?? .now, calendar: calendar)
        }
        return grouped
            .map { (start, runs) -> (Date, Double) in
                let avg = Double(runs.reduce(0) { $0 + $1.legBurnRating }) / Double(runs.count)
                return (start, avg)
            }
            .sorted { $0.0 < $1.0 }
    }
}
