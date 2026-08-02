import SwiftUI

/// Run-specific input fields shown inside `ActiveSessionView` when the
/// session type is `.easyRun` or `.thresholdRun`. Captures distance, duration,
/// leg-burn rating, and an optional interval notes field. Pace auto-renders.
struct RunLogFields: View {
    @Binding var distanceText: String
    @Binding var durationText: String
    @Binding var legBurnRating: Int
    @Binding var intervalDescription: String

    @Environment(\.unitFormatter) private var unit

    private var distanceMeters: Double? { unit.parseDistance(distanceText) }
    private var durationSeconds: Int? { unit.parseDuration(durationText) }

    private var derivedPace: String {
        guard let d = distanceMeters, let s = durationSeconds,
              let pace = UnitFormatter.paceSecondsPerKm(distanceMeters: d, durationSeconds: s)
        else { return "—" }
        return unit.formatPace(secondsPerKm: pace)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("RUN LOG")
                .font(.caption.weight(.bold))
                .foregroundStyle(Theme.accent)

            HStack(spacing: 12) {
                inputField(label: "Distance",
                           placeholder: unit.distancePlaceholder,
                           text: $distanceText,
                           keyboard: .decimalPad)
                inputField(label: "Time",
                           placeholder: unit.durationPlaceholder,
                           text: $durationText,
                           keyboard: .numbersAndPunctuation)
            }

            HStack {
                Text("Pace")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Theme.textSecondary)
                Spacer()
                Text(derivedPace)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(Theme.textPrimary)
                    .contentTransition(.numericText())
            }

            Divider().overlay(Theme.stroke)

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Lower-leg burn")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Theme.textSecondary)
                    Spacer()
                    Text("\(legBurnRating) / 5")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Theme.textPrimary)
                }
                HStack(spacing: 4) {
                    ForEach(1...5, id: \.self) { value in
                        Button {
                            legBurnRating = value
                        } label: {
                            Circle()
                                .fill(value <= legBurnRating ? Theme.accent : Theme.surface)
                                .overlay(Circle().stroke(Theme.stroke, lineWidth: 1))
                                .frame(width: 32, height: 32)
                                .overlay(Text("\(value)")
                                    .font(.footnote.weight(.semibold))
                                    .foregroundStyle(value <= legBurnRating ? .black : Theme.textSecondary))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Intervals actually done (optional)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Theme.textSecondary)
                TextField("e.g. 6×1km @ 4:47 avg", text: $intervalDescription)
                    .textFieldStyle(.roundedBorder)
            }
        }
        .cardStyle()
    }

    private func inputField(label: String, placeholder: String,
                            text: Binding<String>, keyboard: UIKeyboardType) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label.uppercased())
                .font(.caption2.weight(.semibold))
                .foregroundStyle(Theme.textSecondary)
            TextField(placeholder, text: text)
                .keyboardType(keyboard)
                .textFieldStyle(.roundedBorder)
        }
    }
}
