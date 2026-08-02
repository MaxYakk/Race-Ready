import SwiftUI

/// Centralized design tokens. Use these instead of literal colors / fonts
/// throughout the app so the look stays cohesive and tweakable.
public enum Theme {

    // MARK: - Colors

    /// Electric blue accent — drives buttons, active selection, progress fill.
    public static let accent = Color("AccentColor")

    /// Hard background (true black for AMOLED-friendly dark mode).
    public static let background = Color.black

    /// Card / elevated surface.
    public static let surface = Color(white: 0.08)

    /// Subtle stroke for separating cards.
    public static let stroke = Color(white: 0.15)

    /// Primary text.
    public static let textPrimary = Color.white

    /// Muted text for labels, captions.
    public static let textSecondary = Color(white: 0.65)

    /// Warning / dropped status.
    public static let warning = Color.orange

    // MARK: - Typography

    /// Big numeric display (countdown days).
    public static let displayHuge: Font = .system(size: 64, weight: .bold, design: .rounded)

    /// Card titles.
    public static let title: Font = .system(.title2, design: .rounded, weight: .semibold)

    /// Subtitle / metadata.
    public static let caption: Font = .system(.subheadline, design: .default, weight: .regular)

    // MARK: - Spacing

    public static let cardCornerRadius: CGFloat = 16
    public static let cardPadding: CGFloat = 16
    public static let sectionSpacing: CGFloat = 24
}

/// Convenience view modifier: applies the standard card style (rounded surface,
/// subtle stroke, padding).
public struct CardStyle: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .padding(Theme.cardPadding)
            .background(
                RoundedRectangle(cornerRadius: Theme.cardCornerRadius, style: .continuous)
                    .fill(Theme.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cardCornerRadius, style: .continuous)
                    .stroke(Theme.stroke, lineWidth: 1)
            )
    }
}

public extension View {
    func cardStyle() -> some View { modifier(CardStyle()) }
}
