import SwiftUI
import Charts

/// Line chart showing the weekly average leg-burn rating (1–5).
/// Helps spot loading spikes that precede shin-splint risk.
struct LegBurnTrendChart: View {
    let trend: [(weekStart: Date, averageBurn: Double)]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("LOWER-LEG BURN TREND")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Theme.accent)
                Spacer()
                Text("0 (none) → 5 (severe)")
                    .font(.caption2)
                    .foregroundStyle(Theme.textSecondary)
            }

            if trend.isEmpty {
                emptyState
            } else {
                chart
            }
        }
        .cardStyle()
    }

    private var chart: some View {
        Chart {
            ForEach(trend, id: \.weekStart) { entry in
                LineMark(
                    x: .value("Week", entry.weekStart, unit: .weekOfYear),
                    y: .value("Burn", entry.averageBurn)
                )
                .foregroundStyle(Theme.accent)
                .interpolationMethod(.monotone)
                PointMark(
                    x: .value("Week", entry.weekStart, unit: .weekOfYear),
                    y: .value("Burn", entry.averageBurn)
                )
                .foregroundStyle(Theme.accent)
                .symbolSize(60)
            }
        }
        .chartYScale(domain: 0...5)
        .chartXAxis {
            AxisMarks(values: .stride(by: .weekOfYear)) { _ in
                AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                    .foregroundStyle(Theme.textSecondary)
                AxisGridLine().foregroundStyle(Theme.stroke)
            }
        }
        .chartYAxis {
            AxisMarks(values: [0, 1, 2, 3, 4, 5]) { _ in
                AxisValueLabel().foregroundStyle(Theme.textSecondary)
                AxisGridLine().foregroundStyle(Theme.stroke.opacity(0.5))
            }
        }
        .frame(height: 160)
    }

    private var emptyState: some View {
        Text("Rate your lower-leg burn after run sessions to chart fatigue trends here.")
            .font(.footnote)
            .foregroundStyle(Theme.textSecondary)
            .frame(maxWidth: .infinity, minHeight: 100)
            .multilineTextAlignment(.center)
    }
}
