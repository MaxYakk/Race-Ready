import SwiftUI

/// Static race-day reference view: ordered splits with target paces, transition
/// total target, and the common-mistakes list. Content from `RaceDayPlan`.
struct RaceDayPlanView: View {
    @Environment(\.unitFormatter) private var unit

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.sectionSpacing) {
                summaryCard
                splitsCard
                mistakesCard
            }
            .padding(20)
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle("Race Day Plan")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("TARGET")
                .font(.caption.weight(.bold))
                .foregroundStyle(Theme.accent)
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(unit.formatDuration(seconds: RaceDayPlan.totalTargetSeconds))
                    .font(Theme.displayHuge)
                    .foregroundStyle(Theme.textPrimary)
                Text("total")
                    .font(.subheadline)
                    .foregroundStyle(Theme.textSecondary)
            }
            Text("Transitions: ≤ \(unit.formatDuration(seconds: RaceDayPlan.transitionTargetSeconds))")
                .font(.caption)
                .foregroundStyle(Theme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
    }

    private var splitsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("ORDERED SPLITS")
                .font(.caption.weight(.bold))
                .foregroundStyle(Theme.accent)
            ForEach(Array(RaceDayPlan.splits.enumerated()), id: \.offset) { idx, split in
                splitRow(idx: idx + 1, split: split)
            }
        }
        .cardStyle()
    }

    private func splitRow(idx: Int, split: RaceDayPlan.Split) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("\(idx).")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(Theme.textSecondary)
                    .frame(width: 24, alignment: .trailing)
                Text(split.name)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Theme.textPrimary)
                Spacer()
                Text(unit.formatDuration(seconds: split.targetSeconds))
                    .font(.subheadline.weight(.semibold).monospacedDigit())
                    .foregroundStyle(Theme.accent)
            }
            if let pace = split.paceSecondsPerKm {
                Text("Pace target \(unit.formatPace(secondsPerKm: pace))")
                    .font(.caption2)
                    .foregroundStyle(Theme.textSecondary)
                    .padding(.leading, 32)
            }
            if let cue = split.cue {
                Text("• \(cue)")
                    .font(.caption)
                    .italic()
                    .foregroundStyle(Theme.textSecondary)
                    .padding(.leading, 32)
            }
            Divider().overlay(Theme.stroke).padding(.leading, 32)
        }
    }

    private var mistakesCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("COMMON FIRST-TIMER MISTAKES")
                .font(.caption.weight(.bold))
                .foregroundStyle(Theme.warning)
            ForEach(RaceDayPlan.commonMistakes, id: \.self) { mistake in
                HStack(alignment: .top, spacing: 6) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.caption2)
                        .foregroundStyle(Theme.warning)
                    Text(mistake)
                        .font(.footnote)
                        .foregroundStyle(Theme.textSecondary)
                }
            }
        }
        .cardStyle()
    }
}
