import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var context

    @Query(sort: \SessionLog.date, order: .reverse) private var logs: [SessionLog]
    @Query private var runs: [RunLog]
    @Query private var settingsList: [UserSettings]
    @Query private var queueStates: [QueueState]   // triggers re-render after mutations
    @Query private var activeStates: [ActiveSessionState]

    @State private var showSkipSheet = false
    @State private var showSwapSheet = false
    @State private var showActiveSession = false
    @State private var showSettings = false

    private var settings: UserSettings? { settingsList.first }

    private var queueService: QueueService { QueueService(context: context) }

    private var completedSessions: Int {
        settings?.manualSessionCountOverride ?? logs.count
    }

    private var currentPhase: Phase {
        PlanEngine.phase(forCompletedSessions: completedSessions)
    }

    private var currentWeek: Int {
        PlanEngine.weekNumber(forCompletedSessions: completedSessions)
    }

    private var analytics: AnalyticsService {
        AnalyticsService(logs: logs, runs: runs, benchmarks: [])
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.sectionSpacing) {
                    CountdownHeader(
                        raceDate: settings?.raceDate ?? UserSettings.defaultRaceDate,
                        now: .now
                    )

                    phaseWeekIndicator

                    if let resumeTemplate = resumeTemplate {
                        resumeBanner(for: resumeTemplate)
                    }

                    if let upNext = queueService.upNext() {
                        UpNextCard(
                            template: upNext,
                            onStart: { showActiveSession = true },
                            onSkip:  { showSkipSheet = true },
                            onSwap:  { showSwapSheet = true }
                        )
                    } else {
                        emptyQueueCard
                    }

                    QueuePreviewList(templates: Array(queueService.upcoming(limit: 4).dropFirst()))
                        .cardStyle()

                    WeeklyMileageBar(
                        currentMeters: analytics.currentWeekRunMeters(),
                        targetMeters: currentPhase.targetWeeklyRunMeters
                    )
                    .cardStyle()
                }
                .padding(20)
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("RaceReady")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showSettings = true } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .sheet(isPresented: $showSkipSheet) {
                if let upNext = queueService.upNext() {
                    SkipSessionSheet(
                        template: upNext,
                        onReschedule: {
                            queueService.skipReschedule()
                            try? context.save()
                        },
                        onDrop: {
                            queueService.skipDrop()
                            try? context.save()
                        }
                    )
                    .presentationDetents([.medium])
                }
            }
            .sheet(isPresented: $showSwapSheet) {
                if let upNext = queueService.upNext() {
                    SwapSessionSheet(
                        currentType: upNext.sessionType,
                        onSelect: { newType in
                            queueService.swap(toType: newType)
                            try? context.save()
                        }
                    )
                    .presentationDetents([.medium, .large])
                }
            }
            .fullScreenCover(isPresented: $showActiveSession) {
                if let template = resumeTemplate ?? queueService.upNext() {
                    ActiveSessionView(template: template) {
                        showActiveSession = false
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
        }
    }

    private var phaseWeekIndicator: some View {
        HStack(spacing: 12) {
            badge(text: "WEEK \(currentWeek)")
            badge(text: "PHASE \(currentPhase.number) · \(currentPhase.title.uppercased())")
            Spacer()
        }
    }

    private func badge(text: String) -> some View {
        Text(text)
            .font(.caption.weight(.bold))
            .foregroundStyle(Theme.accent)
            .padding(.horizontal, 10).padding(.vertical, 5)
            .background(Theme.accent.opacity(0.12))
            .clipShape(Capsule())
    }

    // MARK: - Resume

    private var resumeTemplate: SessionTemplate? {
        guard let state = activeStates.first else { return nil }
        return TemplateStore(context: context).template(id: state.templateId)
    }

    private func resumeBanner(for template: SessionTemplate) -> some View {
        Button {
            showActiveSession = true
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "play.circle.fill")
                    .font(.title)
                    .foregroundStyle(Theme.accent)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Session in progress")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Theme.accent)
                    Text(template.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.textPrimary)
                }
                Spacer()
                Text("RESUME")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Theme.background)
                    .padding(.horizontal, 12).padding(.vertical, 6)
                    .background(Theme.accent, in: Capsule())
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: Theme.cardCornerRadius, style: .continuous)
                    .fill(Theme.accent.opacity(0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cardCornerRadius, style: .continuous)
                    .stroke(Theme.accent.opacity(0.5), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private var emptyQueueCard: some View {
        VStack(spacing: 8) {
            Image(systemName: "flag.checkered")
                .font(.largeTitle)
                .foregroundStyle(Theme.accent)
            Text("Queue complete")
                .font(Theme.title)
            Text("You've worked through every session in the plan. Open Settings → Reset Queue to start over.")
                .font(.subheadline)
                .foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .cardStyle()
    }
}
