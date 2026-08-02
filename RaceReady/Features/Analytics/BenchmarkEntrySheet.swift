import SwiftUI
import SwiftData

/// Modal form for logging a new `BenchmarkEntry`. Adapts input fields based
/// on whether the chosen kind measures time (mm:ss) or count (reps).
struct BenchmarkEntrySheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    @State private var kind: BenchmarkKind = .fiveK
    @State private var dateLogged: Date = .now
    @State private var timeText: String = ""
    @State private var countText: String = ""
    @State private var notes: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Benchmark") {
                    Picker("Type", selection: $kind) {
                        ForEach(BenchmarkKind.allCases) { k in
                            Text(k.displayName).tag(k)
                        }
                    }
                    DatePicker("Date", selection: $dateLogged, displayedComponents: .date)
                }

                Section("Result") {
                    if kind.measuresTime {
                        TextField("mm:ss or h:mm:ss (e.g. 24:15)", text: $timeText)
                            .keyboardType(.numbersAndPunctuation)
                    } else {
                        TextField("Total reps", text: $countText)
                            .keyboardType(.numberPad)
                    }
                    Text("Target: \(targetLabel)")
                        .font(.caption)
                        .foregroundStyle(Theme.textSecondary)
                }

                Section("Notes") {
                    TextField("Conditions, RPE, anything notable", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section {
                    Text(kind.notes)
                        .font(.caption)
                        .foregroundStyle(Theme.textSecondary)
                }
            }
            .navigationTitle("Log Benchmark")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: save).disabled(!canSave)
                }
            }
        }
    }

    private var targetLabel: String {
        if kind.measuresTime {
            let secs = kind.targetValue
            let h = secs / 3600
            let m = (secs % 3600) / 60
            let s = secs % 60
            return h > 0
                ? String(format: "%d:%02d:%02d", h, m, s)
                : String(format: "%d:%02d", m, s)
        }
        return "\(kind.targetValue) reps"
    }

    private var canSave: Bool {
        if kind.measuresTime { return parseSeconds(timeText) != nil }
        return Int(countText) != nil
    }

    private func parseSeconds(_ input: String) -> Int? {
        let parts = input.split(separator: ":").compactMap { Int($0) }
        switch parts.count {
        case 1: return parts[0]
        case 2: return parts[0] * 60 + parts[1]
        case 3: return parts[0] * 3600 + parts[1] * 60 + parts[2]
        default: return nil
        }
    }

    private func save() {
        let entry = BenchmarkEntry(
            date: dateLogged,
            kind: kind,
            valueSeconds: kind.measuresTime ? parseSeconds(timeText) : nil,
            valueCount: kind.measuresTime ? nil : Int(countText),
            notes: notes
        )
        context.insert(entry)
        try? context.save()
        dismiss()
    }
}
