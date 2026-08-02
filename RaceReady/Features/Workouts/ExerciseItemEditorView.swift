import SwiftUI
import SwiftData

/// Edit a single `ItemRecord`. Numeric fields use canonical SI internally and
/// display in the user's chosen unit system via `UnitFormatter`.
struct ExerciseItemEditorView: View {
    @Bindable var item: ItemRecord
    @Environment(\.modelContext) private var context
    @Environment(\.unitFormatter) private var unit

    var body: some View {
        Form {
            Section("Name") {
                TextField("Exercise name", text: $item.name)
            }

            Section("Volume") {
                optionalIntField("Sets", value: $item.sets, range: 1...20)
                optionalIntField("Reps", value: $item.reps, range: 1...100)
                optionalIntField("Rep range low", value: $item.repsLow, range: 1...100)
                optionalIntField("Rep range high", value: $item.repsHigh, range: 1...100)
            }

            Section("Load") {
                weightField
                distanceField
                durationField(label: "Duration", value: $item.durationSeconds)
                durationField(label: "Rest", value: $item.restSeconds)
            }

            Section("Notes") {
                TextField("Qualifier (e.g. RPE 8, /leg)", text: Binding(
                    get: { item.qualifier ?? "" },
                    set: { item.qualifier = $0.isEmpty ? nil : $0 }
                ))
                TextField("Cue", text: Binding(
                    get: { item.cue ?? "" },
                    set: { item.cue = $0.isEmpty ? nil : $0 }
                ), axis: .vertical)
                .lineLimit(2...4)
            }
        }
        .scrollContentBackground(.hidden)
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle("Edit Exercise")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear { try? context.save() }
    }

    // MARK: - Field helpers

    private func optionalIntField(_ label: String, value: Binding<Int?>, range: ClosedRange<Int>) -> some View {
        HStack {
            Text(label)
            Spacer()
            if let current = value.wrappedValue {
                Stepper("\(current)", value: Binding(
                    get: { current },
                    set: { value.wrappedValue = $0 }
                ), in: range)
                .labelsHidden()
                Text("\(current)")
                    .foregroundStyle(Theme.textSecondary)
                    .frame(minWidth: 32)
                Button {
                    value.wrappedValue = nil
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Theme.textSecondary)
                }
                .buttonStyle(.plain)
            } else {
                Button("Set") { value.wrappedValue = range.lowerBound }
                    .foregroundStyle(Theme.accent)
            }
        }
    }

    private var weightField: some View {
        HStack {
            Text("Weight")
            Spacer()
            if let kg = item.weightKg {
                Text(unit.formatWeight(kg: kg))
                    .foregroundStyle(Theme.textSecondary)
                Stepper("", value: Binding(
                    get: { kg },
                    set: { item.weightKg = $0 }
                ), in: 0...500, step: unit.system == .metric ? 2.5 : 2.27) // ~5 lb
                .labelsHidden()
                Button {
                    item.weightKg = nil
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Theme.textSecondary)
                }
                .buttonStyle(.plain)
            } else {
                Button("Set") { item.weightKg = 20 }
                    .foregroundStyle(Theme.accent)
            }
        }
    }

    private var distanceField: some View {
        HStack {
            Text("Distance")
            Spacer()
            if let m = item.distanceMeters {
                Text(unit.formatDistance(meters: m))
                    .foregroundStyle(Theme.textSecondary)
                Stepper("", value: Binding(
                    get: { m },
                    set: { item.distanceMeters = $0 }
                ), in: 0...50_000, step: m >= 400 ? 100 : 5)
                .labelsHidden()
                Button {
                    item.distanceMeters = nil
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Theme.textSecondary)
                }
                .buttonStyle(.plain)
            } else {
                Button("Set") { item.distanceMeters = 25 }
                    .foregroundStyle(Theme.accent)
            }
        }
    }

    private func durationField(label: String, value: Binding<Int?>) -> some View {
        HStack {
            Text(label)
            Spacer()
            if let seconds = value.wrappedValue {
                Text(unit.formatDuration(seconds: seconds))
                    .foregroundStyle(Theme.textSecondary)
                Stepper("", value: Binding(
                    get: { seconds },
                    set: { value.wrappedValue = $0 }
                ), in: 0...7_200, step: 15)
                .labelsHidden()
                Button {
                    value.wrappedValue = nil
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Theme.textSecondary)
                }
                .buttonStyle(.plain)
            } else {
                Button("Set") { value.wrappedValue = 30 }
                    .foregroundStyle(Theme.accent)
            }
        }
    }
}
