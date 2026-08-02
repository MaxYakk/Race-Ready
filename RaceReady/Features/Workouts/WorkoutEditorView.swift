import SwiftUI
import SwiftData

/// Edit a single `TemplateRecord`: title, type, week, blocks, items.
/// Changes are persisted live to SwiftData via the bound record.
struct WorkoutEditorView: View {
    @Bindable var record: TemplateRecord
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var pendingItem: ItemRecord?

    private var sortedBlocks: [BlockRecord] {
        record.blocks.sorted { $0.orderIndex < $1.orderIndex }
    }

    var body: some View {
        Form {
            metadataSection

            ForEach(sortedBlocks) { block in
                blockSection(block)
            }

            Section {
                Button {
                    _ = TemplateStore(context: context).addBlock(to: record)
                } label: {
                    Label("Add Block", systemImage: "plus.square.on.square")
                        .foregroundStyle(Theme.accent)
                }
            }

            Section {
                Button {
                    QueueService(context: context).append(templateId: record.id)
                    try? context.save()
                    dismiss()
                } label: {
                    Label("Add to Queue", systemImage: "plus.circle.fill")
                        .foregroundStyle(Theme.accent)
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle(record.title)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(item: $pendingItem) { item in
            ExerciseItemEditorView(item: item)
        }
        .onDisappear { try? context.save() }
    }

    // MARK: - Metadata

    private var metadataSection: some View {
        Section("Workout") {
            TextField("Title", text: $record.title)
            Picker("Type", selection: Binding(
                get: { record.sessionType },
                set: { record.sessionTypeRaw = $0.rawValue }
            )) {
                ForEach(SessionType.allCases) { type in
                    Label(type.displayName, systemImage: type.iconName).tag(type)
                }
            }
            Stepper("Week \(record.weekNumber)", value: $record.weekNumber, in: 1...18)
            Stepper(
                "Duration: \(record.estimatedDurationSeconds / 60) min",
                value: Binding(
                    get: { record.estimatedDurationSeconds / 60 },
                    set: { record.estimatedDurationSeconds = $0 * 60 }
                ),
                in: 5...180,
                step: 5
            )
            if let subtitle = record.subtitle {
                TextField("Subtitle", text: Binding(
                    get: { subtitle },
                    set: { record.subtitle = $0.isEmpty ? nil : $0 }
                ))
            } else {
                Button("Add subtitle") { record.subtitle = "" }
                    .foregroundStyle(Theme.accent)
            }
        }
    }

    // MARK: - Block + items

    private func blockSection(_ block: BlockRecord) -> some View {
        Section {
            TextField("Block title", text: Binding(
                get: { block.title },
                set: { block.title = $0 }
            ))
            .font(.headline)

            ForEach(block.items.sorted { $0.orderIndex < $1.orderIndex }) { item in
                Button { pendingItem = item } label: {
                    itemRow(item)
                }
                .buttonStyle(.plain)
            }
            .onDelete { offsets in
                let sorted = block.items.sorted { $0.orderIndex < $1.orderIndex }
                for index in offsets {
                    TemplateStore(context: context).deleteItem(sorted[index])
                }
            }

            Button {
                let item = TemplateStore(context: context).addItem(to: block)
                pendingItem = item
            } label: {
                Label("Add Exercise", systemImage: "plus")
                    .foregroundStyle(Theme.accent)
            }

            Button(role: .destructive) {
                TemplateStore(context: context).deleteBlock(block)
            } label: {
                Label("Delete Block", systemImage: "trash")
            }
        } header: {
            Text("Block")
        }
    }

    @ViewBuilder
    private func itemRow(_ item: ItemRecord) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(item.name.isEmpty ? "Untitled exercise" : item.name)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Theme.textPrimary)
                let summary = ItemSummary.text(for: item.toValue())
                if !summary.isEmpty {
                    Text(summary)
                        .font(.caption)
                        .foregroundStyle(Theme.textSecondary)
                }
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(Theme.textSecondary)
        }
        .contentShape(Rectangle())
    }
}

/// Shared helper so the editor row and the active-session reference list
/// can render a consistent one-line summary.
enum ItemSummary {
    static func text(for item: ExerciseItem) -> String {
        var parts: [String] = []
        if let sets = item.sets, let reps = item.reps {
            parts.append("\(sets)×\(reps)")
        } else if let sets = item.sets, let low = item.repsLow, let high = item.repsHigh {
            parts.append("\(sets)×\(low)–\(high)")
        } else if let sets = item.sets {
            parts.append("\(sets) sets")
        } else if let reps = item.reps {
            parts.append("\(reps) reps")
        }
        if let kg = item.weightKg { parts.append(String(format: "%.0f kg", kg)) }
        if let m = item.distanceMeters {
            parts.append(m >= 400 ? String(format: "%.1f km", m / 1000) : String(format: "%.0f m", m))
        }
        if let sec = item.durationSeconds {
            parts.append(sec >= 60 ? "\(sec / 60) min" : "\(sec)s")
        }
        if let q = item.qualifier { parts.append(q) }
        return parts.joined(separator: " · ")
    }
}
