import Foundation
import SwiftData

/// Persisted record that the user completed a session. Created when the user
/// taps "Complete Session" in the Active Session view.
@Model
public final class SessionLog {
    /// Stable id of the `SessionTemplate` this log records (e.g. "wk03-pushDay-0").
    public var templateId: String

    public var date: Date

    /// Raw value of `SessionType`. Stored as String so it survives schema changes
    /// and is exportable to CSV.
    public var sessionTypeRaw: String

    public var weekNumber: Int

    /// Raw value of `Phase`.
    public var phaseRaw: String

    public var durationSeconds: Int

    public var notes: String

    /// JSON-encoded `SessionTemplate` captured at the moment of completion.
    /// This snapshot is what History renders for the session, so later edits
    /// to the underlying template never rewrite what the user actually did.
    public var snapshotJSON: String?

    /// Title from the template at the moment of completion, denormalized for
    /// quick rendering in History rows without decoding the snapshot.
    public var templateTitle: String

    /// Optional run details — present only when `sessionType.isRun`.
    @Relationship(deleteRule: .cascade, inverse: \RunLog.session)
    public var runLog: RunLog?

    public init(
        templateId: String,
        date: Date,
        sessionType: SessionType,
        weekNumber: Int,
        phase: Phase,
        durationSeconds: Int,
        notes: String = "",
        templateTitle: String = "",
        snapshotJSON: String? = nil,
        runLog: RunLog? = nil
    ) {
        self.templateId = templateId
        self.date = date
        self.sessionTypeRaw = sessionType.rawValue
        self.weekNumber = weekNumber
        self.phaseRaw = phase.rawValue
        self.durationSeconds = durationSeconds
        self.notes = notes
        self.templateTitle = templateTitle
        self.snapshotJSON = snapshotJSON
        self.runLog = runLog
    }

    /// Decode the snapshot back into a `SessionTemplate` (nil if there is no
    /// snapshot or it can't be decoded — legacy logs created before snapshotting).
    public var snapshot: SessionTemplate? {
        guard let json = snapshotJSON, let data = json.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(SessionTemplate.self, from: data)
    }

    public var sessionType: SessionType {
        SessionType(rawValue: sessionTypeRaw) ?? .pushDay
    }

    public var phase: Phase {
        Phase(rawValue: phaseRaw) ?? .base
    }
}
