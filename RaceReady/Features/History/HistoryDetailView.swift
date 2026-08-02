import SwiftUI

/// Detail screen for a completed session. Renders the snapshot of exercises
/// that was captured at the moment the user tapped Complete, so later edits
/// to the underlying template don't rewrite history.
struct HistoryDetailView: View {
    let log: SessionLog
    @Environment(\.unitFormatter) private var unit

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.sectionSpacing) {
                headerCard

                if let run = log.runLog {
                    runCard(run)
                }

                if !log.notes.isEmpty {
                    notesCard
                }

                if let snapshot = log.snapshot {
                    ExerciseReferenceList(template: snapshot)
                } else {
                    Text("No exercise snapshot was captured for this session.")
                        .font(.footnote)
                        .foregroundStyle(Theme.textSecondary)
                }
            }
            .padding(20)
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle(log.templateTitle.isEmpty ? log.sessionType.displayName : log.templateTitle)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                Image(systemName: log.sessionType.iconName)
                    .font(.title2)
                    .foregroundStyle(Theme.accent)
                    .frame(width: 36, height: 36)
                    .background(Theme.accent.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                VStack(alignment: .leading, spacing: 2) {
                    Text(log.sessionType.displayName)
                        .font(Theme.title)
                        .foregroundStyle(Theme.textPrimary)
                    Text("Week \(log.weekNumber) · \(log.phase.title)")
                        .font(.caption)
                        .foregroundStyle(Theme.textSecondary)
                }
                Spacer()
            }
            HStack(spacing: 16) {
                metric("DURATION", unit.formatDuration(seconds: log.durationSeconds))
                Divider().frame(height: 32).overlay(Theme.stroke)
                metric("DATE", log.date.formatted(.dateTime.month(.abbreviated).day()))
            }
            .padding(.top, 4)
        }
        .cardStyle()
    }

    private func runCard(_ run: RunLog) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("RUN")
                .font(.caption.weight(.bold))
                .foregroundStyle(Theme.accent)
            HStack(spacing: 16) {
                metric("DISTANCE", unit.formatDistance(meters: run.distanceMeters, style: .runScale))
                Divider().frame(height: 32).overlay(Theme.stroke)
                if let pace = run.paceSecondsPerKm {
                    metric("PACE", unit.formatPace(secondsPerKm: pace))
                    Divider().frame(height: 32).overlay(Theme.stroke)
                }
                metric("BURN", "\(run.legBurnRating)/5")
            }
            if !run.intervalDescription.isEmpty {
                Text(run.intervalDescription)
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
            }
        }
        .cardStyle()
    }

    private var notesCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("NOTES")
                .font(.caption.weight(.bold))
                .foregroundStyle(Theme.accent)
            Text(log.notes)
                .font(.subheadline)
                .foregroundStyle(Theme.textPrimary)
        }
        .cardStyle()
    }

    private func metric(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption2.weight(.bold))
                .foregroundStyle(Theme.textSecondary)
            Text(value)
                .font(.title3.weight(.semibold))
                .foregroundStyle(Theme.textPrimary)
        }
    }
}
