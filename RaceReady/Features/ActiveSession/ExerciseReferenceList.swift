import SwiftUI

/// Read-only rendering of a `SessionTemplate`'s exercise blocks. Used inside
/// `ActiveSessionView` for lift days, circuits, and run prescriptions.
struct ExerciseReferenceList: View {
    let template: SessionTemplate

    @Environment(\.unitFormatter) private var unit

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            if let prescription = template.intervalPrescription {
                intervalBlock(prescription)
            }

            ForEach(template.blocks) { block in
                blockView(block)
            }

            if !template.notes.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("NOTES")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Theme.textSecondary)
                    ForEach(template.notes, id: \.self) { note in
                        Text("• \(note)")
                            .font(.footnote)
                            .foregroundStyle(Theme.textSecondary)
                    }
                }
                .padding(.top, 8)
            }
        }
    }

    // MARK: - Interval prescription

    private func intervalBlock(_ p: IntervalPrescription) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("INTERVAL TARGET")
                .font(.caption.weight(.bold))
                .foregroundStyle(Theme.textSecondary)
            Text(p.description)
                .font(.body.weight(.semibold))
                .foregroundStyle(Theme.textPrimary)
            HStack(spacing: 12) {
                if let pace = p.repTargetPaceSecondsPerKm {
                    pill("Target pace: \(unit.formatPace(secondsPerKm: pace))")
                }
                pill("Rest: \(unit.formatDuration(seconds: p.restSeconds))")
            }
        }
        .cardStyle()
    }

    // MARK: - Exercise block

    private func blockView(_ block: ExerciseBlock) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(block.title.uppercased())
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Theme.accent)
                Spacer()
                if let subtitle = block.subtitle {
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundStyle(Theme.textSecondary)
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                ForEach(block.items) { item in
                    exerciseRow(item)
                }
            }
        }
        .cardStyle()
    }

    private func exerciseRow(_ item: ExerciseItem) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.name)
                .font(.body.weight(.medium))
                .foregroundStyle(Theme.textPrimary)
            HStack(spacing: 8) {
                ForEach(setRepMetrics(for: item), id: \.self) { pill($0) }
            }
            if let cue = item.cue {
                Text(cue)
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
                    .italic()
            }
        }
    }

    private func setRepMetrics(for item: ExerciseItem) -> [String] {
        var parts: [String] = []
        if let sets = item.sets {
            if let reps = item.reps {
                parts.append("\(sets) × \(reps)")
            } else if let low = item.repsLow, let high = item.repsHigh {
                parts.append("\(sets) × \(low)–\(high)")
            } else {
                parts.append("\(sets) sets")
            }
        }
        if let kg = item.weightKg {
            parts.append(unit.formatWeight(kg: kg))
        }
        if let m = item.distanceMeters {
            parts.append(unit.formatDistance(meters: m))
        }
        if let secs = item.durationSeconds {
            parts.append(unit.formatDuration(seconds: secs))
        }
        if let rest = item.restSeconds {
            parts.append("rest \(unit.formatDuration(seconds: rest))")
        }
        if let qualifier = item.qualifier {
            parts.append(qualifier)
        }
        return parts
    }

    private func pill(_ text: String) -> some View {
        Text(text)
            .font(.caption2.weight(.medium))
            .foregroundStyle(Theme.textSecondary)
            .padding(.horizontal, 8).padding(.vertical, 3)
            .background(Theme.stroke)
            .clipShape(Capsule())
    }
}
