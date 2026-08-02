import SwiftUI

/// Per-phase section in the Plan tab. Lists templates grouped by week, each
/// week collapsible.
struct PhaseSection: View {
    let phase: Phase
    let templates: [SessionTemplate]

    @State private var expandedWeeks: Set<Int> = []

    private var weeks: [Int] {
        Array(Set(templates.map(\.weekNumber))).sorted()
    }

    private func sessions(in week: Int) -> [SessionTemplate] {
        templates
            .filter { $0.weekNumber == week }
            .sorted { $0.slot < $1.slot }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header

            ForEach(weeks, id: \.self) { week in
                weekDisclosure(week)
            }
        }
        .cardStyle()
    }

    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 2) {
                Text("PHASE \(phase.number)")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Theme.accent)
                Text(phase.title)
                    .font(Theme.title)
                    .foregroundStyle(Theme.textPrimary)
                Text("Weeks \(phase.weekRange.lowerBound)–\(phase.weekRange.upperBound) · \(phase.sessionsPerWeek)/wk")
                    .font(.caption2)
                    .foregroundStyle(Theme.textSecondary)
            }
            Spacer()
        }
    }

    private func weekDisclosure(_ week: Int) -> some View {
        let isExpanded = expandedWeeks.contains(week)
        return VStack(alignment: .leading, spacing: 8) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    if isExpanded { expandedWeeks.remove(week) } else { expandedWeeks.insert(week) }
                }
            } label: {
                HStack {
                    Text("Week \(week)")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.textPrimary)
                    Spacer()
                    Text("\(sessions(in: week).count) sessions")
                        .font(.caption)
                        .foregroundStyle(Theme.textSecondary)
                    Image(systemName: "chevron.right")
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Theme.textSecondary)
                }
                .padding(.vertical, 4)
            }
            .buttonStyle(.plain)

            if isExpanded {
                VStack(spacing: 8) {
                    ForEach(sessions(in: week)) { template in
                        SessionTemplateRow(template: template)
                    }
                }
            }

            Divider().overlay(Theme.stroke)
        }
    }
}
