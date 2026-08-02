import Foundation

/// Builds a CSV export of all `SessionLog` / `RunLog` records. Both metric
/// and imperial columns are emitted so the file is unambiguous regardless
/// of the user's current display preference.
public enum CSVExporter {

    private static let header = [
        "date",
        "session_type",
        "week",
        "phase",
        "duration_seconds",
        "distance_meters",
        "distance_miles",
        "run_duration_seconds",
        "pace_seconds_per_km",
        "pace_seconds_per_mile",
        "leg_burn_rating",
        "interval_description",
        "notes"
    ].joined(separator: ",")

    public static func buildCSV(logs: [SessionLog]) -> String {
        let rows = logs
            .sorted { $0.date < $1.date }
            .map(row(for:))
        return ([header] + rows).joined(separator: "\n") + "\n"
    }

    /// Writes the CSV to a temporary file and returns the URL for sharing.
    public static func writeCSVToTempFile(logs: [SessionLog]) throws -> URL {
        let csv = buildCSV(logs: logs)
        let filename = "raceready-export-\(filenameTimestamp()).csv"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        try csv.write(to: url, atomically: true, encoding: .utf8)
        return url
    }

    // MARK: - Row building

    private static func row(for log: SessionLog) -> String {
        let run = log.runLog
        let pace = run?.paceSecondsPerKm
        let meters = run?.distanceMeters
        let miles = meters.map { $0 / 1_609.344 }
        let pacePerMile = pace.map { Int((Double($0) * 1.609344).rounded()) }

        let fields: [String] = [
            isoDate(log.date),
            log.sessionTypeRaw,
            String(log.weekNumber),
            log.phaseRaw,
            String(log.durationSeconds),
            meters.map { String(format: "%.1f", $0) } ?? "",
            miles.map { String(format: "%.3f", $0) } ?? "",
            run.map { String($0.durationSeconds) } ?? "",
            pace.map(String.init) ?? "",
            pacePerMile.map(String.init) ?? "",
            run.map { String($0.legBurnRating) } ?? "",
            escape(run?.intervalDescription ?? ""),
            escape(log.notes)
        ]
        return fields.joined(separator: ",")
    }

    /// CSV-escape a string. Quotes any field containing comma, quote, or newline;
    /// internal quotes are doubled per RFC 4180.
    private static func escape(_ field: String) -> String {
        let needsQuoting = field.contains(",")
            || field.contains("\"")
            || field.contains("\n")
            || field.contains("\r")
        if !needsQuoting { return field }
        let escaped = field.replacingOccurrences(of: "\"", with: "\"\"")
        return "\"\(escaped)\""
    }

    private static let isoFormatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime]
        return f
    }()

    private static func isoDate(_ date: Date) -> String {
        isoFormatter.string(from: date)
    }

    private static func filenameTimestamp() -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyyMMdd-HHmm"
        return f.string(from: .now)
    }
}
