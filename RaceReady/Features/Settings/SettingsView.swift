import SwiftUI
import SwiftData

/// Settings sheet. Exposes race date, daily reminder time, manual
/// session-count override, unit system toggle, queue reset, and CSV export.
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    @Query private var settingsList: [UserSettings]
    @Query(sort: \SessionLog.date, order: .reverse) private var logs: [SessionLog]

    @State private var exportURL: URL?
    @State private var showExportShare = false
    @State private var notificationStatusLabel: String = "—"

    private var settings: UserSettings {
        if let existing = settingsList.first { return existing }
        let new = UserSettings()
        context.insert(new)
        try? context.save()
        return new
    }

    var body: some View {
        NavigationStack {
            Form {
                raceSection
                notificationsSection
                unitsSection
                progressSection
                queueSection
                exportSection
                aboutSection
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .task {
                await refreshNotificationStatus()
            }
            .sheet(isPresented: $showExportShare) {
                if let url = exportURL {
                    ShareSheet(activityItems: [url])
                }
            }
        }
    }

    // MARK: - Sections

    private var raceSection: some View {
        Section("Race") {
            DatePicker(
                "Race Date",
                selection: Binding(
                    get: { settings.raceDate },
                    set: { settings.raceDate = $0; save() }
                ),
                displayedComponents: .date
            )
        }
    }

    private var notificationsSection: some View {
        Section {
            DatePicker(
                "Daily Reminder",
                selection: notificationTimeBinding,
                displayedComponents: .hourAndMinute
            )
            HStack {
                Text("Permission")
                Spacer()
                Text(notificationStatusLabel).foregroundStyle(.secondary)
            }
            Button("Request Permission & Schedule") {
                Task {
                    let granted = await NotificationService.requestAuthorization()
                    settings.hasRequestedNotificationPermission = true
                    save()
                    if granted {
                        await NotificationService.scheduleDailyReminder(
                            hour: settings.notificationHour,
                            minute: settings.notificationMinute
                        )
                    }
                    await refreshNotificationStatus()
                }
            }
        } header: {
            Text("Notifications")
        } footer: {
            Text("A single repeating reminder is delivered at this time daily, even on rest days.")
        }
    }

    private var unitsSection: some View {
        Section("Units") {
            Picker("Display", selection: Binding(
                get: { settings.unitSystem },
                set: { settings.unitSystem = $0; save() }
            )) {
                ForEach(UnitSystem.allCases) { system in
                    Text(system.displayName).tag(system)
                }
            }
            .pickerStyle(.segmented)
        }
    }

    private var progressSection: some View {
        Section {
            Stepper(value: Binding(
                get: { settings.manualSessionCountOverride ?? logs.count },
                set: { settings.manualSessionCountOverride = $0; save() }
            ), in: 0...105) {
                HStack {
                    Text("Sessions completed")
                    Spacer()
                    Text("\(settings.manualSessionCountOverride ?? logs.count)")
                        .foregroundStyle(.secondary)
                }
            }
            if settings.manualSessionCountOverride != nil {
                Button("Clear override (auto-derive from history)") {
                    settings.manualSessionCountOverride = nil
                    save()
                }
                .foregroundStyle(Theme.warning)
            }
        } header: {
            Text("Progress")
        } footer: {
            Text("Defaults to the count of logged sessions. Override only if you've done work outside the app you want reflected in phase / week math.")
        }
    }

    private var queueSection: some View {
        Section {
            Button("Reset queue to default order") {
                QueueService(context: context).resetToDefaultOrder()
                try? context.save()
            }
        } header: {
            Text("Queue")
        } footer: {
            Text("Restores the Mon→Sun template order from the plan, keeping any sessions you've already dropped removed.")
        }
    }

    private var exportSection: some View {
        Section("Data") {
            Button("Export CSV") {
                do {
                    exportURL = try CSVExporter.writeCSVToTempFile(logs: logs)
                    showExportShare = true
                } catch {
                    // Silently no-op; surface in v1.1 with an alert.
                }
            }
            .disabled(logs.isEmpty)
        }
    }

    private var aboutSection: some View {
        Section("About") {
            HStack {
                Text("Race countdown")
                Spacer()
                Text("\(PlanEngine.daysUntilRace(from: .now, raceDate: settings.raceDate)) days")
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Helpers

    private var notificationTimeBinding: Binding<Date> {
        Binding(
            get: {
                var comps = DateComponents()
                comps.hour = settings.notificationHour
                comps.minute = settings.notificationMinute
                return Calendar.current.date(from: comps) ?? .now
            },
            set: { newValue in
                let comps = Calendar.current.dateComponents([.hour, .minute], from: newValue)
                settings.notificationHour = comps.hour ?? 16
                settings.notificationMinute = comps.minute ?? 0
                save()
                Task {
                    await NotificationService.scheduleDailyReminder(
                        hour: settings.notificationHour,
                        minute: settings.notificationMinute
                    )
                }
            }
        )
    }

    private func save() {
        try? context.save()
    }

    private func refreshNotificationStatus() async {
        let status = await NotificationService.currentAuthorizationStatus()
        notificationStatusLabel = {
            switch status {
            case .authorized: return "Allowed"
            case .provisional: return "Provisional"
            case .denied: return "Denied — enable in System Settings"
            case .notDetermined: return "Not requested"
            case .ephemeral: return "Ephemeral"
            @unknown default: return "Unknown"
            }
        }()
    }
}

/// UIKit share-sheet bridge for `ShareLink`-incompatible cases (raw file URL).
private struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ controller: UIActivityViewController, context: Context) {}
}
