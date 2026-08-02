import SwiftUI

/// Shows the user's progress through the current training phase as a horizontal
/// segmented bar (one segment per session, filled segments == completed).
struct PhaseProgressCard: View {
    let phase: Phase
    let completed: Int
    let total: Int

    private var fraction: Double {
        guard total > 0 else { return 0 }
        return Double(completed) / Double(total)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("PHASE \(phase.number) · \(phase.title.uppercased())")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Theme.accent)
                Spacer()
                Text("\(completed) / \(total)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Theme.textPrimary)
            }

            GeometryReader { geo in
                HStack(spacing: 3) {
                    ForEach(0..<max(total, 1), id: \.self) { idx in
                        RoundedRectangle(cornerRadius: 3, style: .continuous)
                            .fill(idx < completed ? Theme.accent : Theme.stroke)
                            .frame(height: 10)
                    }
                }
                .frame(width: geo.size.width)
            }
            .frame(height: 10)

            Text(percentLabel)
                .font(.caption2)
                .foregroundStyle(Theme.textSecondary)
        }
        .cardStyle()
    }

    private var percentLabel: String {
        let pct = Int((fraction * 100).rounded())
        return "\(pct)% complete · Weeks \(phase.weekRange.lowerBound)–\(phase.weekRange.upperBound)"
    }
}
