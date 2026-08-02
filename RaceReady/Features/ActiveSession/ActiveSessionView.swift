import SwiftUI
import SwiftData

/// Walkthrough-style active session: one exercise at a time, tap to check off,
/// pencil to adjust on the fly, arrows to navigate. Timer + completed-set are
/// persisted to `ActiveSessionState` so closing the app doesn't lose progress.
struct ActiveSessionView: View {
    let template: SessionTemplate
    let onDismiss: () -> Void

    @Environment(\.modelContext) private var context
    @Environment(\.unitFormatter) private var unit

    @Query(sort: \SessionLog.date, order: .reverse) private var logs: [SessionLog]
    @Query private var activeStates: [ActiveSessionState]
    @Query private var matchingRecords: [TemplateRecord]

    @State private var elapsedSeconds: Int = 0
    @State private var ticker: Timer?

    @State private var currentIndex: Int = 0
    @State private var pendingEditItem: ItemRecord?
    @State private var pendingEditTemplate: TemplateRecord?
    @State private var showFinishSheet = false
    @State private var showAbandonConfirm = false

    init(template: SessionTemplate, onDismiss: @escaping () -> Void) {
        self.template = template
        self.onDismiss = onDismiss
        let id = template.id
        self._matchingRecords = Query(filter: #Predicate<TemplateRecord> { $0.id == id })
    }

    // MARK: - Derived state

    private var liveRecord: TemplateRecord? { matchingRecords.first }

    private var liveTemplate: SessionTemplate {
        liveRecord?.toValue() ?? template
    }

    /// Flattened, ordered list of every exercise in the workout. The walkthrough
    /// navigates this; checkmarks key off `ItemRecord.id.uuidString`.
    private var orderedItems: [ItemRecord] {
        guard let record = liveRecord else { return [] }
        return record.blocks
            .sorted { $0.orderIndex < $1.orderIndex }
            .flatMap { $0.items.sorted { $0.orderIndex < $1.orderIndex } }
    }

    private var activeState: ActiveSessionState? {
        activeStates.first { $0.templateId == template.id }
    }

    private var completedItemIds: Set<String> {
        Set(activeState?.completedItemIds ?? [])
    }

    private var currentItem: ItemRecord? {
        guard !orderedItems.isEmpty, currentIndex < orderedItems.count else { return nil }
        return orderedItems[currentIndex]
    }

    private var currentBlockTitle: String? {
        guard let item = currentItem, let block = item.block else { return nil }
        return block.title
    }

    private var allChecked: Bool {
        !orderedItems.isEmpty && orderedItems.allSatisfy { completedItemIds.contains($0.id.uuidString) }
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(spacing: 20) {
                        timerHeader
                        progressBar

                        if liveTemplate.sessionType.isRun {
                            runFieldsCard
                        }

                        if let item = currentItem {
                            exerciseCard(item)
                        } else {
                            allDoneCard
                        }

                        notesCard
                    }
                    .padding(20)
                    .padding(.bottom, 120)
                }

                bottomBar
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle(liveTemplate.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        showAbandonConfirm = true
                    } label: {
                        Image(systemName: "xmark")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Theme.textSecondary)
                            .padding(6)
                            .background(Theme.surface, in: Circle())
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        pendingEditTemplate = liveRecord
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Theme.accent)
                            .padding(6)
                            .background(Theme.accent.opacity(0.12), in: Circle())
                    }
                    .disabled(liveRecord == nil)
                }
            }
            .navigationDestination(item: $pendingEditItem) { item in
                ExerciseItemEditorView(item: item)
            }
            .navigationDestination(item: $pendingEditTemplate) { record in
                WorkoutEditorView(record: record)
            }
            .sheet(isPresented: $showAbandonConfirm) {
                abandonSheet
                    .presentationDetents([.height(280)])
                    .presentationDragIndicator(.visible)
                    .presentationBackground(Theme.background)
            }
            .sheet(isPresented: $showFinishSheet) {
                finishSheet
                    .presentationDetents([.height(340)])
                    .presentationDragIndicator(.visible)
                    .presentationBackground(Theme.background)
            }
        }
        .onAppear(perform: handleAppear)
        .onDisappear(perform: stopTicker)
    }

    // MARK: - Lifecycle

    private func handleAppear() {
        // Resume or create the persistent state.
        if activeState == nil {
            let state = ActiveSessionState(templateId: template.id)
            context.insert(state)
            try? context.save()
        }
        // Jump to the first un-checked item so resuming lands on the right card.
        if let firstOpen = orderedItems.firstIndex(where: { !completedItemIds.contains($0.id.uuidString) }) {
            currentIndex = firstOpen
        } else if !orderedItems.isEmpty {
            currentIndex = orderedItems.count - 1
        }
        startTicker()
    }

    private func startTicker() {
        stopTicker()
        tick()
        ticker = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            Task { @MainActor in tick() }
        }
    }

    private func stopTicker() {
        ticker?.invalidate()
        ticker = nil
    }

    private func tick() {
        guard let started = activeState?.startedAt else { return }
        elapsedSeconds = Int(Date().timeIntervalSince(started))
    }

    // MARK: - Header / progress

    private var timerHeader: some View {
        VStack(spacing: 6) {
            Text(unit.formatDuration(seconds: elapsedSeconds))
                .font(.system(size: 54, weight: .bold, design: .rounded).monospacedDigit())
                .foregroundStyle(Theme.textPrimary)
                .contentTransition(.numericText())
            HStack(spacing: 8) {
                Image(systemName: liveTemplate.sessionType.iconName)
                    .foregroundStyle(Theme.accent)
                Text("Week \(liveTemplate.weekNumber) · \(liveTemplate.phase.title)")
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 4)
    }

    private var progressBar: some View {
        let done = completedItemIds.count
        let total = max(orderedItems.count, 1)
        return VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("\(done) of \(orderedItems.count) done")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Theme.textSecondary)
                Spacer()
                Text("EST. \(unit.formatDuration(seconds: liveTemplate.estimatedDurationSeconds))")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Theme.textSecondary)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Theme.surface).frame(height: 8)
                    Capsule().fill(Theme.accent)
                        .frame(width: geo.size.width * CGFloat(done) / CGFloat(total), height: 8)
                        .animation(.easeInOut(duration: 0.2), value: done)
                }
            }
            .frame(height: 8)
        }
    }

    // MARK: - Exercise card

    private func exerciseCard(_ item: ItemRecord) -> some View {
        let isDone = completedItemIds.contains(item.id.uuidString)
        return VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    if let block = currentBlockTitle {
                        Text(block.uppercased())
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(Theme.accent)
                    }
                    Text("Exercise \(currentIndex + 1) of \(orderedItems.count)")
                        .font(.caption)
                        .foregroundStyle(Theme.textSecondary)
                }
                Spacer()
                Button { pendingEditItem = item } label: {
                    Image(systemName: "pencil")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(Theme.accent)
                        .padding(8)
                        .background(Theme.accent.opacity(0.12), in: Circle())
                }
                .buttonStyle(.plain)
            }

            Text(item.name.isEmpty ? "Untitled exercise" : item.name)
                .font(.system(.title, design: .rounded, weight: .bold))
                .foregroundStyle(Theme.textPrimary)

            statsGrid(item)

            if let cue = item.cue, !cue.isEmpty {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundStyle(Theme.accent)
                    Text(cue)
                        .font(.subheadline)
                        .foregroundStyle(Theme.textSecondary)
                }
                .padding(10)
                .background(Theme.accent.opacity(0.08), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            }

            Button {
                toggle(item)
            } label: {
                HStack {
                    Image(systemName: isDone ? "checkmark.circle.fill" : "circle")
                        .font(.title3)
                    Text(isDone ? "Done" : "Mark Done")
                        .font(.headline)
                    Spacer()
                }
                .padding(14)
                .foregroundStyle(isDone ? Theme.background : Theme.accent)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(isDone ? Theme.accent : Theme.accent.opacity(0.12))
                )
            }
            .buttonStyle(.plain)

            Button {
                skipCurrent()
            } label: {
                HStack {
                    Image(systemName: "forward.fill")
                        .font(.subheadline)
                    Text("Skip")
                        .font(.headline)
                    Spacer()
                }
                .padding(14)
                .foregroundStyle(Theme.textSecondary)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Theme.surface)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Theme.stroke, lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
        }
        .cardStyle()
    }

    private func statsGrid(_ item: ItemRecord) -> some View {
        let value = item.toValue()
        let chips: [(String, String)] = [
            value.sets.map { ("SETS", "\($0)") },
            repsChip(value),
            value.weightKg.map { ("WEIGHT", unit.formatWeight(kg: $0)) },
            value.distanceMeters.map { ("DISTANCE", unit.formatDistance(meters: $0)) },
            value.durationSeconds.map { ("TIME", unit.formatDuration(seconds: $0)) },
            value.restSeconds.map { ("REST", unit.formatDuration(seconds: $0)) },
            value.qualifier.map { ("NOTE", $0) }
        ].compactMap { $0 }

        return LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
            ForEach(Array(chips.enumerated()), id: \.offset) { _, chip in
                VStack(alignment: .leading, spacing: 2) {
                    Text(chip.0)
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(Theme.textSecondary)
                    Text(chip.1)
                        .font(.title3.weight(.semibold).monospacedDigit())
                        .foregroundStyle(Theme.textPrimary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Theme.background)
                )
            }
        }
    }

    private func repsChip(_ v: ExerciseItem) -> (String, String)? {
        if let r = v.reps { return ("REPS", "\(r)") }
        if let lo = v.repsLow, let hi = v.repsHigh { return ("REPS", "\(lo)–\(hi)") }
        return nil
    }

    private var allDoneCard: some View {
        VStack(spacing: 10) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 48))
                .foregroundStyle(Theme.accent)
            Text("All exercises checked off")
                .font(Theme.title)
                .foregroundStyle(Theme.textPrimary)
            Text("Tap Finish Session to log it and advance the queue.")
                .font(.subheadline)
                .foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .cardStyle()
    }

    // MARK: - Run inputs

    private var runFieldsCard: some View {
        let bindings = activeStateBinding
        return RunLogFields(
            distanceText: bindings.distance,
            durationText: bindings.duration,
            legBurnRating: bindings.burn,
            intervalDescription: bindings.interval
        )
    }

    private var activeStateBinding: (
        distance: Binding<String>,
        duration: Binding<String>,
        burn: Binding<Int>,
        interval: Binding<String>
    ) {
        let state = activeState
        return (
            distance: Binding(
                get: { state?.distanceText ?? "" },
                set: { state?.distanceText = $0; try? context.save() }
            ),
            duration: Binding(
                get: { state?.durationText ?? "" },
                set: { state?.durationText = $0; try? context.save() }
            ),
            burn: Binding(
                get: { state?.legBurnRating ?? 3 },
                set: { state?.legBurnRating = $0; try? context.save() }
            ),
            interval: Binding(
                get: { state?.intervalDescription ?? "" },
                set: { state?.intervalDescription = $0; try? context.save() }
            )
        )
    }

    // MARK: - Notes

    private var notesCard: some View {
        let notesBinding = Binding(
            get: { activeState?.notes ?? "" },
            set: { activeState?.notes = $0; try? context.save() }
        )
        return VStack(alignment: .leading, spacing: 8) {
            Text("NOTES")
                .font(.caption.weight(.bold))
                .foregroundStyle(Theme.accent)
            TextField(
                "How did it feel? Any modifications?",
                text: notesBinding,
                axis: .vertical
            )
            .lineLimit(2...5)
            .textFieldStyle(.roundedBorder)
        }
        .cardStyle()
    }

    // MARK: - Bottom bar

    private var bottomBar: some View {
        let onLast = currentIndex >= orderedItems.count - 1
        return VStack(spacing: 10) {
            HStack(spacing: 10) {
                Button { goPrev() } label: {
                    Image(systemName: "chevron.left")
                        .font(.title3.weight(.bold))
                        .frame(width: 52, height: 52)
                        .foregroundStyle(currentIndex > 0 ? Theme.textPrimary : Theme.textSecondary.opacity(0.4))
                        .background(Theme.surface, in: Circle())
                        .overlay(Circle().stroke(Theme.stroke, lineWidth: 1))
                }
                .disabled(currentIndex <= 0)
                .buttonStyle(.plain)

                Button {
                    if onLast {
                        showFinishSheet = true
                    } else {
                        goNext()
                    }
                } label: {
                    HStack {
                        Spacer()
                        Text(onLast ? "Finish Session" : "Next")
                            .font(.headline.weight(.bold))
                        if !onLast {
                            Image(systemName: "chevron.right").font(.subheadline.weight(.bold))
                        }
                        Spacer()
                    }
                    .frame(height: 52)
                    .foregroundStyle(Theme.background)
                    .background(Theme.accent, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
                }
                .buttonStyle(.plain)
            }

            // Always-available secondary finish, useful when the user has
            // skipped one or more exercises and doesn't want to scrub to the end.
            if !onLast {
                Button { showFinishSheet = true } label: {
                    Text("Finish session early")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.textSecondary)
                        .padding(.vertical, 6)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
        .padding(.top, 8)
        .background(
            LinearGradient(
                colors: [Theme.background.opacity(0), Theme.background],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()
        )
    }

    // MARK: - Finish / Abandon sheets

    private var finishSheet: some View {
        VStack(spacing: 0) {
            VStack(spacing: 12) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(Theme.accent)
                Text("Finish Session")
                    .font(Theme.title)
                    .foregroundStyle(Theme.textPrimary)
                Text("\(unit.formatDuration(seconds: elapsedSeconds)) · \(completedItemIds.count) of \(orderedItems.count) exercises")
                    .font(.subheadline)
                    .foregroundStyle(Theme.textSecondary)
            }
            .padding(.top, 16)
            .padding(.bottom, 24)

            VStack(spacing: 10) {
                Button { complete() } label: {
                    Text("Log Session")
                        .font(.headline.weight(.bold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .foregroundStyle(Theme.background)
                        .background(Theme.accent, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.plain)

                Button { showFinishSheet = false } label: {
                    Text("Keep Going")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .foregroundStyle(Theme.textPrimary)
                        .background(Theme.surface, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 12)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private var abandonSheet: some View {
        VStack(spacing: 0) {
            VStack(spacing: 10) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(Theme.warning)
                Text("Abandon this session?")
                    .font(Theme.title)
                    .foregroundStyle(Theme.textPrimary)
                Text("Nothing will be logged and the queue won't advance.")
                    .font(.subheadline)
                    .foregroundStyle(Theme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 16)
            .padding(.bottom, 20)

            VStack(spacing: 10) {
                Button {
                    showAbandonConfirm = false
                    abandon()
                } label: {
                    Text("Discard Session")
                        .font(.headline.weight(.bold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .foregroundStyle(.white)
                        .background(Theme.warning, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.plain)

                Button { showAbandonConfirm = false } label: {
                    Text("Keep Going")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .foregroundStyle(Theme.textPrimary)
                        .background(Theme.surface, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 12)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    // MARK: - Actions

    private func toggle(_ item: ItemRecord) {
        guard let state = activeState else { return }
        let key = item.id.uuidString
        var ids = Set(state.completedItemIds)
        if ids.contains(key) { ids.remove(key) } else { ids.insert(key) }
        state.completedItemIds = Array(ids)
        try? context.save()
        // Auto-advance after a brief moment when checking off (not unchecking).
        if ids.contains(key), currentIndex < orderedItems.count - 1 {
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 250_000_000)
                withAnimation { currentIndex += 1 }
            }
        }
    }

    private func goNext() {
        guard currentIndex < orderedItems.count - 1 else { return }
        withAnimation { currentIndex += 1 }
    }

    /// Move past the current exercise without checking it off. If the user is
    /// on the last card, this jumps to the review state instead.
    private func skipCurrent() {
        if currentIndex < orderedItems.count - 1 {
            withAnimation { currentIndex += 1 }
        } else {
            // Already on the last one — advance the index past the end so the
            // "All exercises checked off" / review card shows.
            withAnimation { currentIndex = orderedItems.count }
        }
    }

    private func goPrev() {
        guard currentIndex > 0 else { return }
        withAnimation { currentIndex -= 1 }
    }

    private func abandon() {
        if let state = activeState {
            context.delete(state)
            try? context.save()
        }
        stopTicker()
        onDismiss()
    }

    private func complete() {
        stopTicker()
        let finalElapsed = elapsedSeconds
        let snapshot = liveTemplate

        let phase = PlanEngine.phase(forCompletedSessions: logs.count)

        let runLog: RunLog? = {
            guard snapshot.sessionType.isRun, let state = activeState else { return nil }
            guard let meters = unit.parseDistance(state.distanceText), meters > 0,
                  let seconds = unit.parseDuration(state.durationText), seconds > 0
            else { return nil }
            return RunLog(
                distanceMeters: meters,
                durationSeconds: seconds,
                legBurnRating: state.legBurnRating,
                intervalDescription: state.intervalDescription
            )
        }()

        let snapshotJSON: String? = {
            guard let data = try? JSONEncoder().encode(snapshot) else { return nil }
            return String(data: data, encoding: .utf8)
        }()

        let log = SessionLog(
            templateId: snapshot.id,
            date: .now,
            sessionType: snapshot.sessionType,
            weekNumber: snapshot.weekNumber,
            phase: phase,
            durationSeconds: finalElapsed,
            notes: activeState?.notes ?? "",
            templateTitle: snapshot.title,
            snapshotJSON: snapshotJSON,
            runLog: runLog
        )
        context.insert(log)
        if let runLog { context.insert(runLog) }

        QueueService(context: context).advance()

        if let state = activeState {
            context.delete(state)
        }

        try? context.save()
        showFinishSheet = false
        onDismiss()
    }
}
