import Foundation
import SwiftData

/// Singleton-by-convention model holding user preferences. Created on first
/// launch via `UserSettings.bootstrap(in:)`.
@Model
public final class UserSettings {
    public var raceDate: Date

    /// 0–23
    public var notificationHour: Int

    /// 0–59
    public var notificationMinute: Int

    /// Manual override: forces phase + week math to a specific session count.
    /// Nil = auto-derived from completed session count.
    public var manualSessionCountOverride: Int?

    /// Raw value of `UnitSystem`. Default `.imperial`.
    public var unitSystemRaw: String

    /// Whether we've already requested notification permission from the user.
    public var hasRequestedNotificationPermission: Bool

    public init(
        raceDate: Date = UserSettings.defaultRaceDate,
        notificationHour: Int = 16,
        notificationMinute: Int = 0,
        manualSessionCountOverride: Int? = nil,
        unitSystem: UnitSystem = .imperial,
        hasRequestedNotificationPermission: Bool = false
    ) {
        self.raceDate = raceDate
        self.notificationHour = notificationHour
        self.notificationMinute = notificationMinute
        self.manualSessionCountOverride = manualSessionCountOverride
        self.unitSystemRaw = unitSystem.rawValue
        self.hasRequestedNotificationPermission = hasRequestedNotificationPermission
    }

    public var unitSystem: UnitSystem {
        get { UnitSystem(rawValue: unitSystemRaw) ?? .imperial }
        set { unitSystemRaw = newValue.rawValue }
    }

    /// Canonical race date: 2026-09-18 in user's local calendar at 00:00.
    public static var defaultRaceDate: Date {
        var components = DateComponents()
        components.year = 2026
        components.month = 9
        components.day = 18
        return Calendar.current.date(from: components) ?? Date()
    }
}
