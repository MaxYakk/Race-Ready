import SwiftUI
import Charts

/// Weekly run distance bar chart with a faint target line overlay derived from
/// the current phase. Empty state shown when there are no runs yet.
struct WeeklyMileageChart: View {
    let weeks: [(weekStart: Date, meters: Double)]
    let targetMeters: Double

    @Environment(\.unitFormatter) private var unit

    private var displayUnitLabel: String {
        unit.system == .metric ? "km" : "mi"
    }

    private func toDisplay(_ meters: Double) -> Double {
        unit.system == .metric ? meters / 1_000 : meters / 1_609.344
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("WEEKLY MILEAGE")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Theme.accent)
                Spacer()
                Text("Target \(unit.formatDistance(meters: targetMeters, style: .runScale))")
                    .font(.caption2)
                    .foregroundStyle(Theme.textSecondary)
            }

            if weeks.isEmpty {
                emptyState
            } else {
                chart
            }
        }
        .cardStyle()
    }

    private var chart: some View {
        Chart {
            ForEach(weeks, id: \.weekStart) { week in
                BarMark(
                    x: .value("Week", week.weekStart, unit: .weekOfYear),
                    y: .value(displayUnitLabel, toDisplay(week.meters))
                )
                .foregroundStyle(Theme.accent.gradient)
                .cornerRadius(4)
            }
            RuleMark(y: .value("Target", toDisplay(targetMeters)))
                .foregroundStyle(Theme.warning.opacity(0.7))
                .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [4, 4]))
                .annotation(position: .top, alignment: .trailing) {
                    Text("Target")
                        .font(.caption2)
                        .foregroundStyle(Theme.warning)
                }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .weekOfYear)) { value in
                AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                    .foregroundStyle(Theme.textSecondary)
                AxisGridLine().foregroundStyle(Theme.stroke)
            }
        }
        .chartYAxis {
            AxisMarks { _ in
                AxisValueLabel().foregroundStyle(Theme.textSecondary)
                AxisGridLine().foregroundStyle(Theme.stroke.opacity(0.5))
            }
        }
        .frame(height: 180)
    }

    private var emptyState: some View {
        VStack(spacing: 6) {
            Image(systemName: "chart.bar.xaxis")
                .font(.title2)
                .foregroundStyle(Theme.textSecondary)
            Text("Log a run to start tracking weekly mileage.")
                .font(.footnote)
                .foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, minHeight: 120)
    }
}
