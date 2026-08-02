import SwiftUI
import SwiftData

/// Top-level "Workouts" tab: lists every template in the plan + any user-created
/// days. From here the user can create, edit, delete, or queue any workout.
struct WorkoutsListView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: [SortDescriptor(\TemplateRecord.weekNumber), SortDescriptor(\TemplateRecord.slot)])
    private var records: [TemplateRecord]

    @State private var pendingEdit: TemplateRecord?
    @State private var queueToast: String?
    @State private var showResetConfirm = false

    private var grouped: [(week: Int, records: [TemplateRecord])] {
        Dictionary(grouping: records, by: \.weekNumber)
            .map { (week: $0.key, records: $0.value.sorted { $0.slot < $1.slot }) }
            .sorted { $0.week < $1.week }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    customSection
                    ForEach(grouped, id: \.week) { group in
                        weekSection(week: group.week, records: group.records)
                    }
                }
                .padding(20)
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("Workouts")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button("New Workout", systemImage: "plus") { createNew() }
                        Button("Reset Plan to Default", systemImage: "arrow.uturn.backward", role: .destructive) {
                            showResetConfirm = true
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundStyle(Theme.accent)
                    }
                }
            }
            .navigationDestination(item: $pendingEdit) { record in
                WorkoutEditorView(record: record)
            }
            .overlay(alignment: .bottom) {
                if let toast = queueToast {
                    Text(toast)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.textPrimary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(.ultraThinMaterial, in: Capsule())
                        .padding(.bottom, 24)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .animation(.easeInOut, value: queueToast)
            .confirmationDialog("Reset Plan to Default?", isPresented: $showResetConfirm) {
                Button("Reset and discard custom edits", role: .destructive) {
                    TemplateStore(context: context).resetToPlanData()
                    QueueService(context: context).resetToDefaultOrder()
                    try? context.save()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This re-seeds all sessions from the bundled plan. Your custom edits and user-created workouts will be removed.")
            }
        }
    }

    // MARK: - Sections

    private var customSection: some View {
        let custom = records.filter(\.isUserCreated)
        return Group {
            if !custom.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    sectionHeader(title: "Custom Workouts", systemImage: "sparkles")
                    ForEach(custom) { record in
                        WorkoutRow(
                            record: record,
                            onTap: { pendingEdit = record },
                            onAddToQueue: { addToQueue(record) },
                            onDelete: { delete(record) }
                        )
                    }
                }
            }
        }
    }

    private func weekSection(week: Int, records: [TemplateRecord]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader(title: "Week \(week)", systemImage: "calendar")
            ForEach(records) { record in
                WorkoutRow(
                    record: record,
                    onTap: { pendingEdit = record },
                    onAddToQueue: { addToQueue(record) },
                    onDelete: record.isUserCreated ? { delete(record) } : nil
                )
            }
        }
    }

    private func sectionHeader(title: String, systemImage: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: systemImage)
                .font(.caption.weight(.bold))
                .foregroundStyle(Theme.accent)
            Text(title)
                .font(.headline)
                .foregroundStyle(Theme.textPrimary)
        }
    }

    // MARK: - Actions

    private func createNew() {
        let record = TemplateStore(context: context).createBlank()
        pendingEdit = record
    }

    private func addToQueue(_ record: TemplateRecord) {
        QueueService(context: context).append(templateId: record.id)
        try? context.save()
        showToast("Added “\(record.title)” to queue")
    }

    private func delete(_ record: TemplateRecord) {
        // Also strip it from any queue ordering so we don't leave a dangling id.
        let queue = QueueService(context: context).fetchOrCreate()
        queue.orderedTemplateIds.removeAll { $0 == record.id }
        queue.droppedTemplateIds.removeAll { $0 == record.id }
        TemplateStore(context: context).delete(record)
    }

    private func showToast(_ message: String) {
        queueToast = message
        Task {
            try? await Task.sleep(nanoseconds: 1_800_000_000)
            await MainActor.run { queueToast = nil }
        }
    }
}

// MARK: - Row

private struct WorkoutRow: View {
    let record: TemplateRecord
    let onTap: () -> Void
    let onAddToQueue: () -> Void
    let onDelete: (() -> Void)?

    @Environment(\.unitFormatter) private var unit

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Image(systemName: record.sessionType.iconName)
                    .font(.headline)
                    .foregroundStyle(Theme.accent)
                    .frame(width: 32, height: 32)
                    .background(Theme.accent.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(record.title)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Theme.textPrimary)
                        if record.isUserCreated {
                            Text("CUSTOM")
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(Theme.accent)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Theme.accent.opacity(0.15), in: Capsule())
                        }
                    }
                    Text("\(record.sessionType.displayName) · \(unit.formatDuration(seconds: record.estimatedDurationSeconds))")
                        .font(.caption)
                        .foregroundStyle(Theme.textSecondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Theme.textSecondary)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Theme.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(Theme.stroke, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button("Add to Queue", systemImage: "plus.circle", action: onAddToQueue)
            if let onDelete {
                Button("Delete", systemImage: "trash", role: .destructive, action: onDelete)
            }
        }
    }
}
