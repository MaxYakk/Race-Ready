import Foundation
import SwiftData

/// Manages the persisted session queue and the skip/swap mutations the user
/// applies from the Dashboard.
///
/// All methods are synchronous and mutate the `QueueState` in the provided
/// `ModelContext`; callers are responsible for `try? context.save()`.
public struct QueueService {
    public let context: ModelContext
    private let templates: TemplateStore

    public init(context: ModelContext) {
        self.context = context
        self.templates = TemplateStore(context: context)
    }

    // MARK: - Fetch / bootstrap

    /// Returns the singleton `QueueState`, creating and seeding one on first call.
    /// Assumes `TemplateStore.seedIfNeeded()` has already run.
    public func fetchOrCreate() -> QueueState {
        let descriptor = FetchDescriptor<QueueState>()
        if let existing = (try? context.fetch(descriptor))?.first {
            return existing
        }
        let seeded = QueueState(
            orderedTemplateIds: templates.allRecords().map(\.id),
            droppedTemplateIds: [],
            lastBuiltAt: .now
        )
        context.insert(seeded)
        return seeded
    }

    // MARK: - Reads

    public func upNext() -> SessionTemplate? {
        let q = fetchOrCreate()
        guard let id = q.orderedTemplateIds.first else { return nil }
        return templates.template(id: id)
    }

    public func upcoming(limit: Int) -> [SessionTemplate] {
        let q = fetchOrCreate()
        return q.orderedTemplateIds.prefix(limit).compactMap { templates.template(id: $0) }
    }

    /// Total session templates still in the queue (excluding dropped).
    public func remainingCount() -> Int {
        fetchOrCreate().orderedTemplateIds.count
    }

    // MARK: - Mutations

    /// Pop the head and advance the queue. Called by `ActiveSessionView` after
    /// the user taps "Complete Session". The completed template is removed —
    /// the `SessionLog` itself tracks that it was done.
    @discardableResult
    public func advance() -> SessionTemplate? {
        let q = fetchOrCreate()
        guard !q.orderedTemplateIds.isEmpty else { return nil }
        let removed = q.orderedTemplateIds.removeFirst()
        return templates.template(id: removed)
    }

    /// Skip → Reschedule. Move head to tail.
    public func skipReschedule() {
        let q = fetchOrCreate()
        guard !q.orderedTemplateIds.isEmpty else { return }
        let id = q.orderedTemplateIds.removeFirst()
        q.orderedTemplateIds.append(id)
    }

    /// Skip → Drop. Remove head entirely; record id in droppedTemplateIds.
    public func skipDrop() {
        let q = fetchOrCreate()
        guard !q.orderedTemplateIds.isEmpty else { return }
        let id = q.orderedTemplateIds.removeFirst()
        q.droppedTemplateIds.append(id)
    }

    /// Swap. Promote the earliest queued template of the given type to head.
    /// The displaced head goes to the tail. Returns true if a swap occurred.
    @discardableResult
    public func swap(toType newType: SessionType) -> Bool {
        let q = fetchOrCreate()
        guard let firstIdx = q.orderedTemplateIds.firstIndex(where: { id in
            templates.template(id: id)?.sessionType == newType
        }) else { return false }
        if firstIdx == 0 { return false } // already at head
        let target = q.orderedTemplateIds.remove(at: firstIdx)
        let oldHead = q.orderedTemplateIds.removeFirst()
        q.orderedTemplateIds.insert(target, at: 0)
        q.orderedTemplateIds.append(oldHead)
        return true
    }

    /// Insert a template id at a specific position (used by Workouts tab when
    /// the user adds a custom day to the queue). Clamped to valid range.
    public func insert(templateId: String, at index: Int) {
        let q = fetchOrCreate()
        let clamped = max(0, min(index, q.orderedTemplateIds.count))
        q.orderedTemplateIds.insert(templateId, at: clamped)
    }

    /// Append a template to the tail of the queue.
    public func append(templateId: String) {
        let q = fetchOrCreate()
        q.orderedTemplateIds.append(templateId)
    }

    /// Reset the queue back to the default Mon→Sun order from the template
    /// store, preserving any dropped ids. Used by Settings "Reset Queue".
    public func resetToDefaultOrder() {
        let q = fetchOrCreate()
        let dropped = Set(q.droppedTemplateIds)
        q.orderedTemplateIds = templates.allRecords()
            .map(\.id)
            .filter { !dropped.contains($0) }
        q.lastBuiltAt = .now
    }
}
