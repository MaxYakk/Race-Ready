import SwiftUI

/// Big "X days to race day — September 18" header for the Dashboard.
struct CountdownHeader: View {
    let raceDate: Date
    let now: Date

    private var daysRemaining: Int {
        PlanEngine.daysUntilRace(from: now, raceDate: raceDate)
    }

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMMM d, yyyy"
        return f
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("\(max(daysRemaining, 0))")
                    .font(Theme.displayHuge)
                    .foregroundStyle(Theme.accent)
                    .contentTransition(.numericText())
                Text(daysRemaining == 1 ? "day" : "days")
                    .font(.title3.bold())
                    .foregroundStyle(Theme.textSecondary)
                Spacer()
            }
            Text(daysRemaining < 0
                 ? "Race day was \(Self.dateFormatter.string(from: raceDate))"
                 : "to race day · \(Self.dateFormatter.string(from: raceDate))")
                .font(Theme.caption)
                .foregroundStyle(Theme.textSecondary)
        }
    }
}
