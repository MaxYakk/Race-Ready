import Foundation
import SwiftData

/// Persisted, editable mirror of a `SessionTemplate`. Seeded from `PlanData`
/// on first launch, and thereafter the canonical source of truth for the Plan
/// tab, queue, and Active Session views.
///
/// Why we materialize the static `PlanData` into SwiftData records: it lets the
/// user edit any session (rename, change exercises, swap blocks) or create new
/// custom days without forking the bundled plan source.
@Model
public final class TemplateRecord {
    /// Stable id. For PlanData-seeded templates this matches the original
    /// `SessionTemplate.id` ("wk03-pushDay-0"); for user-created days we use
    /// a UUID-string ("custom-<uuid>") so the queue can reference them.
    @Attribute(.unique) public var id: String

    public var weekNumber: Int
    public var sessionTypeRaw: String
    public var slot: Int
    public var title: String
    public var subtitle: String?
    public var estimatedDurationSeconds: Int
    public var targetRunDistanceMeters: Double?
    public var notes: [String]

    /// True for templates the user added/cloned. Surfaces a "custom" badge in
    /// the Workouts tab and enables deletion (seeded templates are reset-able
    /// but not deletable, to keep the canonical plan recoverable).
    public var isUserCreated: Bool

    /// Flattened `IntervalPrescription`. Nil if this is not a run session.
    public var intervalReps: Int?
    public var intervalRepDistanceMeters: Double?
    public var intervalRepDurationSeconds: Int?
    public var intervalRepTargetPaceSecondsPerKm: Int?
    public var intervalRestSeconds: Int?
    public var intervalDescription: String?

    @Relationship(deleteRule: .cascade, inverse: \BlockRecord.template)
    public var blocks: [BlockRecord] = []

    public init(
        id: String,
        weekNumber: Int,
        sessionType: SessionType,
        slot: Int,
        title: String,
        subtitle: String? = nil,
        estimatedDurationSeconds: Int,
        targetRunDistanceMeters: Double? = nil,
        notes: [String] = [],
        isUserCreated: Bool = false,
        intervalPrescription: IntervalPrescription? = nil
    ) {
        self.id = id
        self.weekNumber = weekNumber
        self.sessionTypeRaw = sessionType.rawValue
        self.slot = slot
        self.title = title
        self.subtitle = subtitle
        self.estimatedDurationSeconds = estimatedDurationSeconds
        self.targetRunDistanceMeters = targetRunDistanceMeters
        self.notes = notes
        self.isUserCreated = isUserCreated
        if let p = intervalPrescription {
            self.intervalReps = p.reps
            self.intervalRepDistanceMeters = p.repDistanceMeters
            self.intervalRepDurationSeconds = p.repDurationSeconds
            self.intervalRepTargetPaceSecondsPerKm = p.repTargetPaceSecondsPerKm
            self.intervalRestSeconds = p.restSeconds
            self.intervalDescription = p.description
        }
    }

    public var sessionType: SessionType {
        SessionType(rawValue: sessionTypeRaw) ?? .pushDay
    }

    public var intervalPrescription: IntervalPrescription? {
        guard let reps = intervalReps,
              let rest = intervalRestSeconds,
              let desc = intervalDescription
        else { return nil }
        return IntervalPrescription(
            reps: reps,
            repDistanceMeters: intervalRepDistanceMeters,
            repDurationSeconds: intervalRepDurationSeconds,
            repTargetPaceSecondsPerKm: intervalRepTargetPaceSecondsPerKm,
            restSeconds: rest,
            description: desc
        )
    }

    /// Convert this record into the value-type `SessionTemplate` used by
    /// existing UI code. Blocks are sorted by `orderIndex`.
    public func toValue() -> SessionTemplate {
        let sortedBlocks = blocks
            .sorted { $0.orderIndex < $1.orderIndex }
            .map { $0.toValue() }
        return SessionTemplate(
            id: id,
            weekNumber: weekNumber,
            sessionType: sessionType,
            slot: slot,
            title: title,
            subtitle: subtitle,
            estimatedDurationSeconds: estimatedDurationSeconds,
            intervalPrescription: intervalPrescription,
            targetRunDistanceMeters: targetRunDistanceMeters,
            blocks: sortedBlocks,
            notes: notes
        )
    }
}

@Model
public final class BlockRecord {
    public var id: UUID
    public var orderIndex: Int
    public var title: String
    public var subtitle: String?

    public var template: TemplateRecord?

    @Relationship(deleteRule: .cascade, inverse: \ItemRecord.block)
    public var items: [ItemRecord] = []

    public init(
        id: UUID = UUID(),
        orderIndex: Int,
        title: String,
        subtitle: String? = nil
    ) {
        self.id = id
        self.orderIndex = orderIndex
        self.title = title
        self.subtitle = subtitle
    }

    public func toValue() -> ExerciseBlock {
        ExerciseBlock(
            title: title,
            subtitle: subtitle,
            items: items.sorted { $0.orderIndex < $1.orderIndex }.map { $0.toValue() }
        )
    }
}

@Model
public final class ItemRecord {
    public var id: UUID
    public var orderIndex: Int
    public var name: String
    public var sets: Int?
    public var reps: Int?
    public var repsLow: Int?
    public var repsHigh: Int?
    public var weightKg: Double?
    public var distanceMeters: Double?
    public var durationSeconds: Int?
    public var restSeconds: Int?
    public var qualifier: String?
    public var cue: String?

    public var block: BlockRecord?

    public init(
        id: UUID = UUID(),
        orderIndex: Int,
        name: String,
        sets: Int? = nil,
        reps: Int? = nil,
        repsLow: Int? = nil,
        repsHigh: Int? = nil,
        weightKg: Double? = nil,
        distanceMeters: Double? = nil,
        durationSeconds: Int? = nil,
        restSeconds: Int? = nil,
        qualifier: String? = nil,
        cue: String? = nil
    ) {
        self.id = id
        self.orderIndex = orderIndex
        self.name = name
        self.sets = sets
        self.reps = reps
        self.repsLow = repsLow
        self.repsHigh = repsHigh
        self.weightKg = weightKg
        self.distanceMeters = distanceMeters
        self.durationSeconds = durationSeconds
        self.restSeconds = restSeconds
        self.qualifier = qualifier
        self.cue = cue
    }

    public func toValue() -> ExerciseItem {
        ExerciseItem(
            name: name,
            sets: sets,
            reps: reps,
            repsLow: repsLow,
            repsHigh: repsHigh,
            weightKg: weightKg,
            distanceMeters: distanceMeters,
            durationSeconds: durationSeconds,
            restSeconds: restSeconds,
            qualifier: qualifier,
            cue: cue
        )
    }
}
