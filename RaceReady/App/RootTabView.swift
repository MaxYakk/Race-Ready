import SwiftUI
import SwiftData

/// 5-tab bar root: Dashboard · Workouts · Analytics · Plan · History.
/// Settings is reached from the Dashboard's toolbar (gear icon).
struct RootTabView: View {
    @Environment(\.modelContext) private var context
    @Query private var settingsList: [UserSettings]

    var body: some View {
        TabView {
            DashboardView()
                .tabItem { Label("Dashboard", systemImage: "house.fill") }

            WorkoutsListView()
                .tabItem { Label("Workouts", systemImage: "dumbbell.fill") }

            AnalyticsView()
                .tabItem { Label("Analytics", systemImage: "chart.bar.fill") }

            PlanView()
                .tabItem { Label("Plan", systemImage: "list.bullet.rectangle") }

            HistoryView()
                .tabItem { Label("History", systemImage: "clock.arrow.circlepath") }
        }
        .environment(\.unitFormatter, UnitFormatter(system: currentSystem))
        .onAppear { ensureSettingsExists() }
    }

    private var currentSystem: UnitSystem {
        settingsList.first?.unitSystem ?? .imperial
    }

    private func ensureSettingsExists() {
        // Seed the template store from PlanData on first launch so the
        // Workouts tab and queue have something to render against.
        TemplateStore(context: context).seedIfNeeded()
        if settingsList.isEmpty {
            context.insert(UserSettings())
            try? context.save()
        }
    }
}

// MARK: - Unit formatter as an environment value

private struct UnitFormatterKey: EnvironmentKey {
    static let defaultValue = UnitFormatter(system: .imperial)
}

public extension EnvironmentValues {
    var unitFormatter: UnitFormatter {
        get { self[UnitFormatterKey.self] }
        set { self[UnitFormatterKey.self] = newValue }
    }
}
