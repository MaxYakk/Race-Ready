import SwiftUI

/// Modal: tap a session type to promote the earliest queued template of that
/// type to the head. The replaced head goes to the tail.
struct SwapSessionSheet: View {
    let currentType: SessionType
    let onSelect: (SessionType) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    Text("Pick a session type to do next.")
                        .font(.subheadline)
                        .foregroundStyle(Theme.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 8)

                    ForEach(SessionType.allCases) { type in
                        Button {
                            onSelect(type)
                            dismiss()
                        } label: {
                            row(for: type)
                        }
                        .disabled(type == currentType)
                        .opacity(type == currentType ? 0.4 : 1)
                    }
                }
                .padding(20)
            }
            .background(Theme.background)
            .navigationTitle("Swap To...")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func row(for type: SessionType) -> some View {
        HStack(spacing: 16) {
            Image(systemName: type.iconName)
                .font(.title3)
                .foregroundStyle(Theme.accent)
                .frame(width: 32)
            Text(type.displayName)
                .font(.headline)
                .foregroundStyle(Theme.textPrimary)
            Spacer()
            if type == currentType {
                Text("Current")
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
            } else {
                Image(systemName: "chevron.right")
                    .foregroundStyle(Theme.textSecondary)
            }
        }
        .padding()
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}
