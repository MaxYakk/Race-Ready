import SwiftUI

/// The headline card on the Dashboard — shows the next session in the queue,
/// its key targets, and the Start / Skip / Swap actions.
struct UpNextCard: View {
    let template: SessionTemplate
    let onStart: () -> Void
    let onSkip: () -> Void
    let onSwap: () -> Void

    @Environment(\.unitFormatter) private var unit

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: template.sessionType.iconName)
                    .font(.title2)
                    .foregroundStyle(Theme.accent)
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(Theme.accent.opacity(0.12)))

                VStack(alignment: .leading, spacing: 2) {
                    Text("UP NEXT")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Theme.textSecondary)
                    Text(template.title)
                        .font(Theme.title)
                        .foregroundStyle(Theme.textPrimary)
                }

                Spacer()

                Menu {
                    Button("Swap", systemImage: "arrow.left.arrow.right", action: onSwap)
                    Button("Skip", systemImage: "forward.fill", role: .destructive, action: onSkip)
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.title2)
                        .foregroundStyle(Theme.textSecondary)
                }
            }

            if let subtitle = template.subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(Theme.textSecondary)
            }

            keyTargetsRow

            Button(action: onStart) {
                HStack {
                    Image(systemName: "play.fill")
                    Text("Start Session")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Theme.accent)
                .foregroundStyle(.black)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
        .cardStyle()
    }

    private var keyTargetsRow: some View {
        HStack(spacing: 16) {
            metric(label: "Duration",
                   value: unit.formatDuration(seconds: template.estimatedDurationSeconds))

            if let d = template.targetRunDistanceMeters {
                metric(label: "Distance",
                       value: unit.formatDistance(meters: d, style: .runScale))
            }

            if let prescription = template.intervalPrescription {
                metric(label: "Reps", value: "\(prescription.reps)")
                if let pace = prescription.repTargetPaceSecondsPerKm {
                    metric(label: "Target", value: unit.formatPace(secondsPerKm: pace))
                }
            }

            Spacer()
        }
    }

    private func metric(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label.uppercased())
                .font(.caption2.weight(.medium))
                .foregroundStyle(Theme.textSecondary)
            Text(value)
                .font(.headline)
                .foregroundStyle(Theme.textPrimary)
        }
    }
}
