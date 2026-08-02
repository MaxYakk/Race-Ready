import SwiftUI

/// Lists logged `BenchmarkEntry` rows grouped by kind, latest-first. "Add"
/// button opens `BenchmarkEntrySheet`.
struct BenchmarkSection: View {
    let entries: [BenchmarkEntry]
    let onAdd: () -> Void

    @Environment(\.unitFormatter) private var unit

    private var grouped: [(kind: BenchmarkKind, entries: [BenchmarkEntry])] {
        let dict = Dictionary(grouping: entries, by: { $0.kind })
        return BenchmarkKind.allCases.map { kind in
            (kind, (dict[kind] ?? []).sorted { $0.date > $1.date })
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("BENCHMARKS")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Theme.accent)
                Spacer()
                Button(action: onAdd) {
                    Label("Log", systemImage: "plus.circle.fill")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.accent)
                }
                .buttonStyle(.plain)
            }

            ForEach(grouped, id: \.kind) { group in
                kindRow(group.kind, entries: group.entries)
            }
        }
        .cardStyle()
    }

    private func kindRow(_ kind: BenchmarkKind, entries: [BenchmarkEntry]) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(kind.displayName)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.textPrimary)
                Spacer()
                Text("Target \(targetLabel(for: kind))")
                    .font(.caption2)
                    .foregroundStyle(Theme.textSecondary)
            }
            if entries.isEmpty {
                Text("Not yet logged")
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
            } else {
                ForEach(entries.prefix(3)) { entry in
                    HStack {
                        Text(entry.date, style: .date)
                            .font(.caption)
                            .foregroundStyle(Theme.textSecondary)
                        Spacer()
                        Text(entry.formattedValue(using: unit))
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(Theme.textPrimary)
                    }
                }
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Theme.background)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(Theme.stroke, lineWidth: 1)
        )
    }

    private func targetLabel(for kind: BenchmarkKind) -> String {
        if kind.measuresTime {
            let secs = kind.targetValue
            let h = secs / 3600
            let m = (secs % 3600) / 60
            let s = secs % 60
            return h > 0
                ? String(format: "%d:%02d:%02d", h, m, s)
                : String(format: "%d:%02d", m, s)
        }
        return "\(kind.targetValue) reps"
    }
}
