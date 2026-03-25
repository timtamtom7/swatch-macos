import AppKit

enum Theme {
    static let backgroundColor = NSColor(red: 0.12, green: 0.12, blue: 0.14, alpha: 1.0)
    static let surfaceColor = NSColor(red: 0.18, green: 0.18, blue: 0.20, alpha: 1.0)
    static let surfaceElevated = NSColor(red: 0.22, green: 0.22, blue: 0.24, alpha: 1.0)
    static let accentColor = NSColor(red: 0.29, green: 0.56, blue: 0.85, alpha: 1.0)
    static let textPrimary = NSColor.white
    static let textSecondary = NSColor(white: 0.6, alpha: 1.0)
    static let borderColor = NSColor(white: 0.3, alpha: 1.0)
    static let hoverColor = NSColor(white: 0.35, alpha: 1.0)

    static let popoverWidth: CGFloat = 360
    static let popoverHeight: CGFloat = 520

    static let cornerRadius: CGFloat = 8
    static let smallRadius: CGFloat = 4

    static let padding: CGFloat = 16
    static let smallPadding: CGFloat = 8
    static let tinyPadding: CGFloat = 4

    static let swatchSize: CGFloat = 120
    static let historyCellSize: CGFloat = 20
}
