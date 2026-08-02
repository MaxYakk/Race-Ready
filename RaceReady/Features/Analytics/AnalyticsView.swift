import SwiftUI
import SwiftData

/// Top-level Analytics tab. Composes the mileage chart, phase progress, PRs,
/// benchmarks, and leg-burn trend, all driven from live `@Query` results.
struct AnalyticsView: View {
    @Query(sort: \SessionLog.date, order: .reverse) private var logs: [SessionLog]
    @Query private var runs: [RunLog]
    @Query(sort: \BenchmarkEntry.date, order: .reverse) private var benchmarks: [BenchmarkEntry]
    @Query private var settingsList: [UserSettings]

    @State private var showBenchmarkSheet = false

    private var settings: UserSettings? { settingsList.first }

    private var completedSessions: Int {
        settings?.manualSessionCountOverride ?? logs.count
    }

    private var currentPhase: Phase {
        PlanEngine.phase(forCompletedSessions: completedSessions)
    }

    private var analytics: AnalyticsService {
        AnalyticsService(logs: logs, runs: runs, benchmarks: benchmarks)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.sectionSpacing) {
                    PhaseProgressCard(
                        phase: currentPhase,
                        completed: analytics.phaseProgress(currentPhase: currentPhase).completed,
                        total: analytics.phaseProgress(currentPhase: currentPhase).total
                    )

                    WeeklyMileageChart(
                        weeks: analytics.weeklyRunMeters(),
                        targetMeters: currentPhase.targetWeeklyRunMeters
                    )

                    PersonalRecordsCard(
                        fastestPaceSecondsPerKm: analytics.fastestPaceSecondsPerKm,
                        longestRunMeters: analytics.longestRunMeters,
                        totalSessions: logs.count,
                        streakDays: analytics.currentStreak()
                    )

                    LegBurnTrendChart(trend: analytics.legBurnTrend())

                    BenchmarkSection(
                        entries: benchmarks,
                        onAdd: { showBenchmarkSheet = true }
                    )
                }
                .padding(20)
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("Analytics")
            .sheet(isPresented: $showBenchmarkSheet) {
                BenchmarkEntrySheet()
            }
        }
    }
}
