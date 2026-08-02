import SwiftUI

/// Slim progress bar showing current-week run distance vs. phase target.
struct WeeklyMileageBar: View {
    let currentMeters: Double
    let targetMeters: Double

    @Environment(\.unitFormatter) private var unit

    private var progress: Double {
        guard targetMeters > 0 else { return 0 }
        return min(currentMeters / targetMeters, 1.5)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("WEEKLY MILEAGE")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Theme.textSecondary)
                Spacer()
                Text("\(unit.formatDistance(meters: currentMeters, style: .runScale)) / \(unit.formatDistance(meters: targetMeters, style: .runScale))")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(Theme.textPrimary)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Theme.surface)
                        .frame(height: 10)
                    Capsule()
                        .fill(progress >= 1 ? Theme.accent : Theme.accent.opacity(0.85))
                        .frame(width: min(geo.size.width * progress, geo.size.width), height: 10)
                }
            }
            .frame(height: 10)
        }
    }
}
