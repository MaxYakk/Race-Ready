import Foundation

/// Pure functions for plan logic — phase detection, week mapping, target mileage.
///
/// **No state**, no SwiftData. Driven solely by `PlanData` constants and the
/// number of sessions the user has completed. This is the single source of
/// truth for "what phase am I in" and "what's my target this week".
public enum PlanEngine {

    /// Determines the user's current phase from completed-session count.
    ///
    /// Boundaries from `Phase.cumulativeSessionCount`:
    /// - 0–36 sessions → .base
    /// - 37–72 → .build
    /// - 73–102 → .peak
    /// - 103+ → .taper
    public static func phase(forCompletedSessions completed: Int) -> Phase {
        if completed < Phase.base.cumulativeSessionCount { return .base }
        if completed < Phase.build.cumulativeSessionCount { return .build }
        if completed < Phase.peak.cumulativeSessionCount { return .peak }
        return .taper
    }

    /// Current week number from completed-session count (1...18).
    /// Uses each phase's `sessionsPerWeek` to map within the phase.
    public static func weekNumber(forCompletedSessions completed: Int) -> Int {
        let phase = phase(forCompletedSessions: completed)
        let priorPhasesSessions: Int = {
            switch phase {
            case .base:  return 0
            case .build: return Phase.base.cumulativeSessionCount
            case .peak:  return Phase.build.cumulativeSessionCount
            case .taper: return Phase.peak.cumulativeSessionCount
            }
        }()
        let sessionsIntoPhase = completed - priorPhasesSessions
        let weeksIntoPhase = sessionsIntoPhase / phase.sessionsPerWeek
        let weekInPlan = phase.weekRange.lowerBound + weeksIntoPhase
        return min(weekInPlan, phase.weekRange.upperBound)
    }

    /// Sessions completed so far inside the current phase (0-indexed count).
    public static func sessionsIntoPhase(completed: Int) -> Int {
        let phase = phase(forCompletedSessions: completed)
        switch phase {
        case .base:  return completed
        case .build: return completed - Phase.base.cumulativeSessionCount
        case .peak:  return completed - Phase.build.cumulativeSessionCount
        case .taper: return completed - Phase.peak.cumulativeSessionCount
        }
    }

    /// Total sessions prescribed for the current phase.
    public static func totalSessions(in phase: Phase) -> Int {
        phase.weekRange.count * phase.sessionsPerWeek
    }

    /// Days remaining until race day (negative if race is past).
    public static func daysUntilRace(from now: Date, raceDate: Date,
                                     calendar: Calendar = .current) -> Int {
        let startOfNow = calendar.startOfDay(for: now)
        let startOfRace = calendar.startOfDay(for: raceDate)
        return calendar.dateComponents([.day], from: startOfNow, to: startOfRace).day ?? 0
    }
}
