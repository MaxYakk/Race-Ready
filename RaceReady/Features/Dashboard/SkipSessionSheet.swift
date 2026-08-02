import SwiftUI

/// Modal: "Reschedule" sends the session to the back of the queue;
/// "Drop" removes it entirely (and reduces effective phase total).
struct SkipSessionSheet: View {
    let template: SessionTemplate
    let onReschedule: () -> Void
    let onDrop: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                VStack(spacing: 6) {
                    Image(systemName: template.sessionType.iconName)
                        .font(.system(size: 36))
                        .foregroundStyle(Theme.accent)
                    Text(template.title)
                        .font(Theme.title)
                    Text("Week \(template.weekNumber) · \(template.sessionType.displayName)")
                        .font(.subheadline)
                        .foregroundStyle(Theme.textSecondary)
                }
                .padding(.top, 16)

                VStack(spacing: 12) {
                    Button {
                        onReschedule()
                        dismiss()
                    } label: {
                        choiceRow(
                            icon: "arrow.uturn.right",
                            title: "Reschedule",
                            subtitle: "Move to the back of the queue. You'll do it later."
                        )
                    }

                    Button(role: .destructive) {
                        onDrop()
                        dismiss()
                    } label: {
                        choiceRow(
                            icon: "trash",
                            title: "Drop",
                            subtitle: "Remove this session entirely. Won't be served again.",
                            isDestructive: true
                        )
                    }
                }

                Spacer()
            }
            .padding(20)
            .background(Theme.background)
            .navigationTitle("Skip Session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func choiceRow(icon: String, title: String, subtitle: String,
                           isDestructive: Bool = false) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(isDestructive ? Theme.warning : Theme.accent)
                .frame(width: 32)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(Theme.textPrimary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
                    .multilineTextAlignment(.leading)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(Theme.textSecondary)
        }
        .padding()
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}
