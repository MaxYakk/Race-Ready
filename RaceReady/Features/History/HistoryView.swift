import SwiftUI
import SwiftData

/// History tab: a chronological list of every `SessionLog` the user has
/// completed, newest first. Swipe-to-delete removes the log (and its cascaded
/// `RunLog`) and rewinds analytics accordingly.
struct HistoryView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \SessionLog.date, order: .reverse) private var logs: [SessionLog]

    var body: some View {
        NavigationStack {
            Group {
                if logs.isEmpty {
                    emptyState
                } else {
                    list
                }
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("History")
        }
    }

    private var list: some View {
        List {
            ForEach(logs) { log in
                NavigationLink {
                    HistoryDetailView(log: log)
                } label: {
                    HistoryRow(log: log)
                }
                .listRowBackground(Theme.surface)
                .listRowSeparatorTint(Theme.stroke)
            }
            .onDelete(perform: delete)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Theme.background)
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.largeTitle)
                .foregroundStyle(Theme.accent)
            Text("No sessions logged yet")
                .font(Theme.title)
                .foregroundStyle(Theme.textPrimary)
            Text("Complete a session from the Dashboard to start your history.")
                .font(.subheadline)
                .foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func delete(at offsets: IndexSet) {
        for index in offsets {
            context.delete(logs[index])
        }
        try? context.save()
    }
}
