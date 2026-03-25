import AppIntents
import Foundation

// MARK: - App Shortcuts Provider

struct SwatchShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: GetCurrentColorIntent(),
            phrases: [
                "Get current \(.applicationName) color",
                "What color is selected in \(.applicationName)"
            ],
            shortTitle: "Current Color",
            systemImageName: "paintpalette"
        )

        AppShortcut(
            intent: CopyColorAsHexIntent(),
            phrases: [
                "Copy \(.applicationName) hex",
                "Copy color as hex from \(.applicationName)"
            ],
            shortTitle: "Copy Hex",
            systemImageName: "doc.on.clipboard"
        )

        AppShortcut(
            intent: GetContrastRatioIntent(),
            phrases: [
                "Get \(.applicationName) contrast ratio",
                "Check contrast in \(.applicationName)"
            ],
            shortTitle: "Contrast Check",
            systemImageName: "circle.lefthalf.filled"
        )
    }
}

// MARK: - Get Current Color Intent

struct GetCurrentColorIntent: AppIntent {
    static var title: LocalizedStringResource = "Get Current Color"
    static var description = IntentDescription("Returns the currently selected color in Swatch")

    static var openAppWhenRun: Bool = false

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let color = await SwatchState.shared.store?.selectedColor ?? SwatchColor(hex: "#000000")

        return .result(dialog: "Current color: \(color.hex). RGB: \(color.rgb.r), \(color.rgb.g), \(color.rgb.b). \(color.hsbString)")
    }
}

// MARK: - Copy Color As Hex Intent

struct CopyColorAsHexIntent: AppIntent {
    static var title: LocalizedStringResource = "Copy Color as Hex"
    static var description = IntentDescription("Copies the current color's hex value to clipboard")

    @Parameter(title: "Format")
    var format: ColorFormatEntity

    static var parameterSummary: some ParameterSummary {
        Summary("Copy current color as \(\.$format)")
    }

    static var openAppWhenRun: Bool = false

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let color = await SwatchState.shared.store?.selectedColor ?? SwatchColor(hex: "#000000")

        let text: String
        switch format.id {
        case "hex":
            text = color.hex
        case "rgb":
            text = color.rgbString
        case "hsb":
            text = color.hsbString
        case "swiftui":
            text = color.swiftUIColor
        default:
            text = color.hex
        }

        await SwatchState.shared.store?.copyToClipboard(text)

        return .result(dialog: "Copied \(text) to clipboard")
    }
}

// MARK: - Get Contrast Ratio Intent

struct GetContrastRatioIntent: AppIntent {
    static var title: LocalizedStringResource = "Get Contrast Ratio"
    static var description = IntentDescription("Checks WCAG contrast between foreground and background")

    @Parameter(title: "Background Hex")
    var backgroundHex: String

    @Parameter(title: "Foreground Hex")
    var foregroundHex: String

    static var parameterSummary: some ParameterSummary {
        Summary("Check contrast \(\.$backgroundHex) on \(\.$foregroundHex)")
    }

    static var openAppWhenRun: Bool = false

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let bg = SwatchColor(hex: backgroundHex)
        let fg = SwatchColor(hex: foregroundHex)
        let contrast = WCAGContrast(background: bg, foreground: fg)

        let level: String
        if contrast.wcagAAA {
            level = "AAA (best)"
        } else if contrast.wcagAA {
            level = "AA"
        } else if contrast.wcagAALarge {
            level = "AA Large"
        } else {
            level = "Fail"
        }

        return .result(dialog: "Contrast \(contrast.ratioString) - \(level)")
    }
}

// MARK: - Color Format Entity

struct ColorFormatEntity: AppEntity {
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Color Format")

    static var defaultQuery = ColorFormatQuery()

    var id: String
    var name: String

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)")
    }

    init(id: String, name: String) {
        self.id = id
        self.name = name
    }
}

struct ColorFormatQuery: EntityQuery {
    func entities(for identifiers: [String]) async throws -> [ColorFormatEntity] {
        allFormats.filter { identifiers.contains($0.id) }
    }

    func suggestedEntities() async throws -> [ColorFormatEntity] {
        allFormats
    }

    func defaultResult() async -> ColorFormatEntity? {
        allFormats.first
    }

    private var allFormats: [ColorFormatEntity] {
        [
            ColorFormatEntity(id: "hex", name: "HEX"),
            ColorFormatEntity(id: "rgb", name: "RGB"),
            ColorFormatEntity(id: "hsb", name: "HSB"),
            ColorFormatEntity(id: "swiftui", name: "SwiftUI Color")
        ]
    }
}
