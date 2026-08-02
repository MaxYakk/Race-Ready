import SwiftUI

/// Single row in the History list. Shows icon, type, date, duration, plus a
/// run-specific summary (distance · pace) when applicable.
struct HistoryRow: View {
    let log: SessionLog
    @Environment(\.unitFormatter) private var unit

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: log.sessionType.iconName)
                .font(.title3)
                .foregroundStyle(Theme.accent)
                .frame(width: 36, height: 36)
                .background(Theme.accent.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text(titleText)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.textPrimary)
                Text(dateLabel)
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
                if let summary = runSummary {
                    Text(summary)
                        .font(.caption2)
                        .foregroundStyle(Theme.accent)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(unit.formatDuration(seconds: log.durationSeconds))
                    .font(.subheadline.weight(.semibold).monospacedDigit())
                    .foregroundStyle(Theme.textPrimary)
                Text("Wk \(log.weekNumber)")
                    .font(.caption2)
                    .foregroundStyle(Theme.textSecondary)
            }
        }
        .padding(.vertical, 8)
    }

    private var titleText: String {
        log.templateTitle.isEmpty ? log.sessionType.displayName : log.templateTitle
    }

    private var dateLabel: String {
        log.date.formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day().hour().minute())
    }

    private var runSummary: String? {
        guard let run = log.runLog else { return nil }
        let dist = unit.formatDistance(meters: run.distanceMeters, style: .runScale)
        guard let pace = run.paceSecondsPerKm else { return dist }
        return "\(dist) · \(unit.formatPace(secondsPerKm: pace))"
    }
}
