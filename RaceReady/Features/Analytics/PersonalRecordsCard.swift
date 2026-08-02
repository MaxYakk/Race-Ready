import SwiftUI

/// Compact grid of headline stats: fastest pace, longest run, total sessions,
/// current streak. Pulled from `AnalyticsService`.
struct PersonalRecordsCard: View {
    let fastestPaceSecondsPerKm: Int?
    let longestRunMeters: Double?
    let totalSessions: Int
    let streakDays: Int

    @Environment(\.unitFormatter) private var unit

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("PERSONAL RECORDS")
                .font(.caption.weight(.bold))
                .foregroundStyle(Theme.accent)

            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible())],
                spacing: 12
            ) {
                statTile(label: "Fastest Pace",
                         value: fastestPaceSecondsPerKm.map { unit.formatPace(secondsPerKm: $0) } ?? "—")
                statTile(label: "Longest Run",
                         value: longestRunMeters.map { unit.formatDistance(meters: $0, style: .runScale) } ?? "—")
                statTile(label: "Sessions Logged", value: "\(totalSessions)")
                statTile(label: "Current Streak", value: streakDays == 1 ? "1 day" : "\(streakDays) days")
            }
        }
        .cardStyle()
    }

    private func statTile(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label.uppercased())
                .font(.caption2.weight(.semibold))
                .foregroundStyle(Theme.textSecondary)
            Text(value)
                .font(.title3.weight(.bold))
                .foregroundStyle(Theme.textPrimary)
                .contentTransition(.numericText())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Theme.background)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(Theme.stroke, lineWidth: 1)
        )
    }
}
