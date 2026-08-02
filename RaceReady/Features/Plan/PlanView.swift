import SwiftUI
import SwiftData

/// Plan tab: 4 phase sections (collapsible by week) + Race Day plan link.
struct PlanView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: [SortDescriptor(\TemplateRecord.weekNumber), SortDescriptor(\TemplateRecord.slot)])
    private var records: [TemplateRecord]

    private var templatesByPhase: [(phase: Phase, templates: [SessionTemplate])] {
        let all = records.map { $0.toValue() }
        return Phase.allCases.map { phase in
            (phase, all.filter { phase.weekRange.contains($0.weekNumber) })
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.sectionSpacing) {
                    NavigationLink {
                        RaceDayPlanView()
                    } label: {
                        raceDayCard
                    }
                    .buttonStyle(.plain)

                    ForEach(templatesByPhase, id: \.phase) { item in
                        PhaseSection(phase: item.phase, templates: item.templates)
                    }
                }
                .padding(20)
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("Plan")
        }
    }

    private var raceDayCard: some View {
        HStack(spacing: 16) {
            Image(systemName: "flag.checkered")
                .font(.title)
                .foregroundStyle(Theme.accent)
                .frame(width: 44, height: 44)
                .background(Theme.accent.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            VStack(alignment: .leading, spacing: 2) {
                Text("Race Day Plan")
                    .font(Theme.title)
                    .foregroundStyle(Theme.textPrimary)
                Text("Target splits · transitions · common mistakes")
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(Theme.textSecondary)
        }
        .cardStyle()
    }
}
