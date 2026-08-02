import SwiftUI

/// Tall, pinned bottom CTA used on `ActiveSessionView`. Renders the running
/// elapsed time on the left and a "Complete Session" tap target on the right.
struct CompleteSessionButton: View {
    let elapsedLabel: String
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("ELAPSED")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.black.opacity(0.6))
                    Text(elapsedLabel)
                        .font(.title3.weight(.bold).monospacedDigit())
                        .foregroundStyle(.black)
                        .contentTransition(.numericText())
                }
                Spacer()
                HStack(spacing: 8) {
                    Text("Complete Session")
                        .font(.headline)
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                }
                .foregroundStyle(.black)
            }
            .padding(.horizontal, 20)
            .frame(height: 64)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(isEnabled ? Theme.accent : Theme.stroke)
            )
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .padding(.horizontal, 20)
        .padding(.bottom, 12)
    }
}
