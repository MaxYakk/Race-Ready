import SwiftUI

/// Small "coming up after this" preview rendered under the UpNextCard.
struct QueuePreviewList: View {
    let templates: [SessionTemplate]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("COMING UP")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Theme.textSecondary)

            if templates.isEmpty {
                Text("Queue is empty — open the Plan tab to see what's next.")
                    .font(.footnote)
                    .foregroundStyle(Theme.textSecondary)
            } else {
                ForEach(templates) { template in
                    HStack(spacing: 12) {
                        Image(systemName: template.sessionType.iconName)
                            .foregroundStyle(Theme.accent)
                            .frame(width: 24)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(template.title)
                                .font(.subheadline)
                                .foregroundStyle(Theme.textPrimary)
                            Text("Week \(template.weekNumber) · \(template.sessionType.displayName)")
                                .font(.caption)
                                .foregroundStyle(Theme.textSecondary)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }
}
