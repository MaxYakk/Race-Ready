import Foundation
import SwiftData

/// CRUD facade over `TemplateRecord` storage. UI code goes through here
/// instead of touching `PlanData` directly — that way every fetch reflects
/// user edits and custom days.
public struct TemplateStore {
    public let context: ModelContext

    public init(context: ModelContext) {
        self.context = context
    }

    // MARK: - Bootstrap

    /// Seeds `TemplateRecord` rows from `PlanData` on first launch. Idempotent:
    /// re-running it after seed is a no-op (checked via existence of any record).
    public func seedIfNeeded() {
        let descriptor = FetchDescriptor<TemplateRecord>()
        if let count = try? context.fetchCount(descriptor), count > 0 {
            return
        }
        for template in PlanData.allTemplates {
            insert(from: template, isUserCreated: false)
        }
        try? context.save()
    }

    /// Wipes all records and re-seeds from `PlanData`. Destroys user edits.
    /// Called from Settings → "Reset plan to original".
    public func resetToPlanData() {
        let descriptor = FetchDescriptor<TemplateRecord>()
        if let all = try? context.fetch(descriptor) {
            for record in all {
                context.delete(record)
            }
        }
        for template in PlanData.allTemplates {
            insert(from: template, isUserCreated: false)
        }
        try? context.save()
    }

    // MARK: - Reads

    public func allRecords() -> [TemplateRecord] {
        let descriptor = FetchDescriptor<TemplateRecord>(
            sortBy: [SortDescriptor(\.weekNumber), SortDescriptor(\.slot)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    public func allTemplates() -> [SessionTemplate] {
        allRecords().map { $0.toValue() }
    }

    public func record(id: String) -> TemplateRecord? {
        var descriptor = FetchDescriptor<TemplateRecord>(
            predicate: #Predicate { $0.id == id }
        )
        descriptor.fetchLimit = 1
        return (try? context.fetch(descriptor))?.first
    }

    public func template(id: String) -> SessionTemplate? {
        record(id: id)?.toValue()
    }

    // MARK: - Writes

    /// Materialize a `SessionTemplate` value into a new record + child rows.
    @discardableResult
    public func insert(from template: SessionTemplate, isUserCreated: Bool) -> TemplateRecord {
        let record = TemplateRecord(
            id: template.id,
            weekNumber: template.weekNumber,
            sessionType: template.sessionType,
            slot: template.slot,
            title: template.title,
            subtitle: template.subtitle,
            estimatedDurationSeconds: template.estimatedDurationSeconds,
            targetRunDistanceMeters: template.targetRunDistanceMeters,
            notes: template.notes,
            isUserCreated: isUserCreated,
            intervalPrescription: template.intervalPrescription
        )
        context.insert(record)
        for (bIdx, block) in template.blocks.enumerated() {
            let blockRecord = BlockRecord(
                orderIndex: bIdx,
                title: block.title,
                subtitle: block.subtitle
            )
            blockRecord.template = record
            context.insert(blockRecord)
            for (iIdx, item) in block.items.enumerated() {
                let itemRecord = ItemRecord(
                    orderIndex: iIdx,
                    name: item.name,
                    sets: item.sets,
                    reps: item.reps,
                    repsLow: item.repsLow,
                    repsHigh: item.repsHigh,
                    weightKg: item.weightKg,
                    distanceMeters: item.distanceMeters,
                    durationSeconds: item.durationSeconds,
                    restSeconds: item.restSeconds,
                    qualifier: item.qualifier,
                    cue: item.cue
                )
                itemRecord.block = blockRecord
                context.insert(itemRecord)
            }
        }
        return record
    }

    /// Create a brand-new user template. Returns the inserted record so the
    /// caller can immediately push an editor screen for it.
    @discardableResult
    public func createBlank(
        sessionType: SessionType = .pushDay,
        weekNumber: Int = 1,
        slot: Int = 99,
        title: String = "Custom Workout"
    ) -> TemplateRecord {
        let record = TemplateRecord(
            id: "custom-\(UUID().uuidString)",
            weekNumber: weekNumber,
            sessionType: sessionType,
            slot: slot,
            title: title,
            estimatedDurationSeconds: 60 * 60,
            isUserCreated: true
        )
        context.insert(record)
        let starterBlock = BlockRecord(orderIndex: 0, title: "Main")
        starterBlock.template = record
        context.insert(starterBlock)
        try? context.save()
        return record
    }

    public func delete(_ record: TemplateRecord) {
        context.delete(record)
        try? context.save()
    }

    public func addBlock(to record: TemplateRecord, title: String = "New block") -> BlockRecord {
        let nextIndex = (record.blocks.map(\.orderIndex).max() ?? -1) + 1
        let block = BlockRecord(orderIndex: nextIndex, title: title)
        block.template = record
        context.insert(block)
        try? context.save()
        return block
    }

    public func deleteBlock(_ block: BlockRecord) {
        context.delete(block)
        try? context.save()
    }

    public func addItem(to block: BlockRecord, name: String = "New exercise") -> ItemRecord {
        let nextIndex = (block.items.map(\.orderIndex).max() ?? -1) + 1
        let item = ItemRecord(orderIndex: nextIndex, name: name)
        item.block = block
        context.insert(item)
        try? context.save()
        return item
    }

    public func deleteItem(_ item: ItemRecord) {
        context.delete(item)
        try? context.save()
    }

    public func save() {
        try? context.save()
    }
}
