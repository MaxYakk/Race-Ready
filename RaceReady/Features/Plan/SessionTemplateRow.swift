import SwiftUI

/// Expandable row showing a single `SessionTemplate` in the Plan tab. Collapsed
/// state shows icon/title/duration; expanded state reveals exercise blocks.
struct SessionTemplateRow: View {
    let template: SessionTemplate
    @State private var expanded: Bool = false
    @Environment(\.unitFormatter) private var unit

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) { expanded.toggle() }
            } label: {
                header
            }
            .buttonStyle(.plain)

            if expanded {
                VStack(alignment: .leading, spacing: 12) {
                    if let subtitle = template.subtitle {
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundStyle(Theme.textSecondary)
                    }
                    ExerciseReferenceList(template: template)
                }
                .padding(.top, 12)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Theme.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Theme.stroke, lineWidth: 1)
        )
    }

    private var header: some View {
        HStack(spacing: 12) {
            Image(systemName: template.sessionType.iconName)
                .font(.headline)
                .foregroundStyle(Theme.accent)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text(template.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.textPrimary)
                Text("~\(unit.formatDuration(seconds: template.estimatedDurationSeconds))")
                    .font(.caption2)
                    .foregroundStyle(Theme.textSecondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .rotationEffect(.degrees(expanded ? 90 : 0))
                .font(.caption.weight(.bold))
                .foregroundStyle(Theme.textSecondary)
        }
    }
}
