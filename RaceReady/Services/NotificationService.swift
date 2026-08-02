import Foundation
import UserNotifications

/// Wraps `UNUserNotificationCenter` for the daily "log your session" reminder.
///
/// Architecture: one repeating `UNCalendarNotificationTrigger` keyed by
/// `dailyReminderIdentifier`. Body text rotates deterministically by day-of-year
/// so the same nudge isn't shown twice in a row.
public enum NotificationService {

    public static let dailyReminderIdentifier = "raceready.daily-reminder"

    private static let bodies: [String] = [
        "How'd today go? Tap to log it before bed.",
        "Quick check-in: any movement today counts.",
        "Rest day or session? Either way — log it.",
        "Don't break the streak. Tap to log.",
        "Sub-1:30 is built one logged session at a time.",
        "30 seconds of logging keeps the trend honest.",
        "Race day's getting closer. How'd training feel?"
    ]

    // MARK: - Authorization

    public static func requestAuthorization() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .badge, .sound])
        } catch {
            return false
        }
    }

    public static func currentAuthorizationStatus() async -> UNAuthorizationStatus {
        await UNUserNotificationCenter.current().notificationSettings().authorizationStatus
    }

    // MARK: - Scheduling

    /// Schedules (or replaces) the daily reminder. Safe to call repeatedly.
    public static func scheduleDailyReminder(hour: Int, minute: Int) async {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [dailyReminderIdentifier])

        let content = UNMutableNotificationContent()
        content.title = "RaceReady"
        content.body = bodyForToday()
        content.sound = .default

        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        let request = UNNotificationRequest(
            identifier: dailyReminderIdentifier,
            content: content,
            trigger: trigger
        )
        try? await center.add(request)
    }

    public static func cancelDailyReminder() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [dailyReminderIdentifier])
    }

    // MARK: - Body rotation

    private static func bodyForToday(calendar: Calendar = .current,
                                     now: Date = .now) -> String {
        let day = calendar.ordinality(of: .day, in: .year, for: now) ?? 1
        return bodies[(day - 1) % bodies.count]
    }
}
