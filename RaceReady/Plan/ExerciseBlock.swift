import Foundation

/// A named group of `ExerciseItem`s — e.g. "Main lifts", "Skill block",
/// "Lower-leg finisher", "Hyrox circuit (4 rounds)".
public struct ExerciseBlock: Codable, Hashable, Identifiable {
    public var id: String { title }

    public let title: String

    /// Optional subtitle: "60 min", "15 min", "4 rounds, 2 min rest between", etc.
    public let subtitle: String?

    public let items: [ExerciseItem]

    public init(title: String, subtitle: String? = nil, items: [ExerciseItem]) {
        self.title = title
        self.subtitle = subtitle
        self.items = items
    }
}
