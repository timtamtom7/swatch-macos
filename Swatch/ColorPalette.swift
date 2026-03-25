import AppKit
import Foundation

// MARK: - Color Palette

struct ColorPalette: Identifiable, Codable {
    let id: UUID
    var name: String
    var colors: [PaletteColor]
    var createdAt: Date
    var modifiedAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        colors: [PaletteColor] = [],
        createdAt: Date = Date(),
        modifiedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.colors = colors
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
    }

    mutating func addColor(_ swatch: SwatchColor) {
        let pc = PaletteColor(hex: swatch.hex, name: nil)
        if !colors.contains(where: { $0.hex.lowercased() == swatch.hex.lowercased() }) {
            colors.append(pc)
            modifiedAt = Date()
        }
    }

    mutating func removeColor(at index: Int) {
        guard index >= 0 && index < colors.count else { return }
        colors.remove(at: index)
        modifiedAt = Date()
    }
}

// MARK: - Palette Color

struct PaletteColor: Identifiable, Codable, Hashable {
    let id: UUID
    var hex: String
    var name: String?
    var position: Int

    init(id: UUID = UUID(), hex: String, name: String? = nil, position: Int = 0) {
        self.id = id
        self.hex = hex
        self.name = name
        self.position = position
    }
}

// MARK: - Color Harmony

enum ColorHarmony {
    case complementary
    case triadic
    case analogous
    case splitComplementary
    case tetradic

    func colors(from hsb: (h: Double, s: Double, b: Double)) -> [(h: Double, s: Double, b: Double)] {
        let h = hsb.h
        let s = hsb.s
        let b = hsb.b

        switch self {
        case .complementary:
            return [
                (h, s, b),
                ((h + 180) .truncatingRemainder(dividingBy: 360), s, b)
            ]
        case .triadic:
            return [
                (h, s, b),
                ((h + 120) .truncatingRemainder(dividingBy: 360), s, b),
                ((h + 240) .truncatingRemainder(dividingBy: 360), s, b)
            ]
        case .analogous:
            return [
                ((h - 30 + 360).truncatingRemainder(dividingBy: 360), s, b),
                (h, s, b),
                ((h + 30).truncatingRemainder(dividingBy: 360), s, b)
            ]
        case .splitComplementary:
            return [
                (h, s, b),
                ((h + 150) .truncatingRemainder(dividingBy: 360), s, b),
                ((h + 210) .truncatingRemainder(dividingBy: 360), s, b)
            ]
        case .tetradic:
            return [
                (h, s, b),
                ((h + 90) .truncatingRemainder(dividingBy: 360), s, b),
                ((h + 180) .truncatingRemainder(dividingBy: 360), s, b),
                ((h + 270) .truncatingRemainder(dividingBy: 360), s, b)
            ]
        }
    }
}

// MARK: - WCAG Contrast

struct WCAGContrast {
    let background: SwatchColor
    let foreground: SwatchColor

    var contrastRatio: Double {
        let l1 = background.relativeLuminance
        let l2 = foreground.relativeLuminance
        let lighter = max(l1, l2)
        let darker = min(l1, l2)
        return (lighter + 0.05) / (darker + 0.05)
    }

    var ratioString: String {
        String(format: "%.2f:1", contrastRatio)
    }

    var wcagAA: Bool {
        contrastRatio >= 4.5
    }

    var wcagAALarge: Bool {
        contrastRatio >= 3.0
    }

    var wcagAAA: Bool {
        contrastRatio >= 7.0
    }

    var wcagAAALarge: Bool {
        contrastRatio >= 4.5
    }
}

// MARK: - Color Palette Store

@MainActor
final class PaletteStore: ObservableObject {
    static let shared = PaletteStore()

    @Published var palettes: [ColorPalette] = []
    @Published var activePalette: ColorPalette?

    private let palettesKey = "swatch_palettes"
    private let activeKey = "swatch_active_palette"

    private init() {
        loadPalettes()
    }

    func createPalette(name: String) -> ColorPalette {
        let palette = ColorPalette(name: name)
        palettes.append(palette)
        savePalettes()
        return palette
    }

    func deletePalette(_ id: UUID) {
        palettes.removeAll { $0.id == id }
        if activePalette?.id == id {
            activePalette = nil
        }
        savePalettes()
    }

    func addColorToActivePalette(_ swatch: SwatchColor) {
        guard var palette = activePalette else { return }
        palette.addColor(swatch)
        if let idx = palettes.firstIndex(where: { $0.id == palette.id }) {
            palettes[idx] = palette
        }
        activePalette = palette
        savePalettes()
    }

    func removeColorFromPalette(_ paletteId: UUID, at index: Int) {
        guard let idx = palettes.firstIndex(where: { $0.id == paletteId }) else { return }
        palettes[idx].removeColor(at: index)
        if activePalette?.id == paletteId {
            activePalette = palettes[idx]
        }
        savePalettes()
    }

    func setActivePalette(_ id: UUID?) {
        if let id = id {
            activePalette = palettes.first { $0.id == id }
        } else {
            activePalette = nil
        }
        if let active = activePalette {
            UserDefaults.standard.set(active.id.uuidString, forKey: activeKey)
        } else {
            UserDefaults.standard.removeObject(forKey: activeKey)
        }
    }

    func exportPalette(_ palette: ColorPalette, format: ExportFormat) -> String {
        switch format {
        case .json:
            return exportJSON(palette)
        case .css:
            return exportCSS(palette)
        case .swift:
            return exportSwift(palette)
        case .swiftUI:
            return exportSwiftUI(palette)
        case .ase:
            return exportASE(palette)
        }
    }

    private func exportJSON(_ palette: ColorPalette) -> String {
        var dict: [[String: String]] = []
        for color in palette.colors {
            var entry: [String: String] = ["hex": color.hex]
            if let name = color.name { entry["name"] = name }
            dict.append(entry)
        }
        let data = try? JSONSerialization.data(withJSONObject: ["name": palette.name, "colors": dict], options: .prettyPrinted)
        return String(data: data ?? Data(), encoding: .utf8) ?? ""
    }

    private func exportCSS(_ palette: ColorPalette) -> String {
        var css = "/* \(palette.name) */\n"
        css += ":root {\n"
        for (i, color) in palette.colors.enumerated() {
            let name = color.name ?? "color-\(i + 1)"
            let safeName = name.lowercased().replacingOccurrences(of: " ", with: "-")
            css += "  --\(safeName): \(color.hex);\n"
        }
        css += "}"
        return css
    }

    private func exportSwift(_ palette: ColorPalette) -> String {
        var swift = "// \(palette.name)\n"
        swift += "enum \(palette.name.replacingOccurrences(of: " ", with: "")) {\n"
        for (i, color) in palette.colors.enumerated() {
            let name = color.name ?? "color\(i + 1)"
            let safeName = name.replacingOccurrences(of: " ", with: "")
            swift += "    static let \(safeName) = Color(hex: \"\(color.hex)\")\n"
        }
        swift += "}"
        return swift
    }

    private func exportSwiftUI(_ palette: ColorPalette) -> String {
        var swift = "import SwiftUI\n\n"
        swift += "// \(palette.name)\n"
        swift += "extension Color {\n"
        for (i, color) in palette.colors.enumerated() {
            let name = color.name ?? "color\(i + 1)"
            let safeName = name.replacingOccurrences(of: " ", with: "")
            swift += "    static let \(safeName) = Color(hex: \"\(color.hex)\")\n"
        }
        swift += "}"
        return swift
    }

    private func exportASE(_ palette: ColorPalette) -> String {
        // Simplified ASE export - just return hex list for now
        return palette.colors.map { "#\($0.hex)" }.joined(separator: "\n")
    }

    private func savePalettes() {
        guard let encoded = try? JSONEncoder().encode(palettes) else { return }
        UserDefaults.standard.set(encoded, forKey: palettesKey)
    }

    private func loadPalettes() {
        guard let data = UserDefaults.standard.data(forKey: palettesKey),
              let decoded = try? JSONDecoder().decode([ColorPalette].self, from: data) else {
            return
        }
        palettes = decoded

        if let activeId = UserDefaults.standard.string(forKey: activeKey),
           let uuid = UUID(uuidString: activeId) {
            activePalette = palettes.first { $0.id == uuid }
        }
    }
}

// MARK: - Export Format

enum ExportFormat: String, CaseIterable {
    case json = "JSON"
    case css = "CSS Variables"
    case swift = "Swift Enum"
    case swiftUI = "SwiftUI Color"
    case ase = "Hex List"
}
