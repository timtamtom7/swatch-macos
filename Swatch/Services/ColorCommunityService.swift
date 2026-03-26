import Foundation
import Network

// MARK: - Color Community Service

@MainActor
final class ColorCommunityService: ObservableObject {
    static let shared = ColorCommunityService()

    @Published var featuredPalettes: [ColorSet] = []
    @Published var trendingPalettes: [ColorSet] = []
    @Published var mySharedPalettes: [ColorSet] = []
    @Published var sharedLinks: [ColorPaletteShare] = []

    private let sharedKey = "swatch_shared"
    private let linksKey = "swatch_links"

    private init() {
        loadSharedPalettes()
        loadSharedLinks()
    }

    // MARK: - Sharing

    func sharePalette(_ palette: ColorSet) -> ColorPaletteShare {
        let share = ColorPaletteShare(paletteId: palette.id)
        sharedLinks.append(share)
        saveSharedLinks()

        if !mySharedPalettes.contains(where: { $0.id == palette.id }) {
            var sharedPalette = palette
            sharedPalette.isPublic = true
            mySharedPalettes.append(sharedPalette)
            saveSharedPalettes()
        }

        return share
    }

    func generateShareLink(for palette: ColorSet) -> String {
        let share = sharePalette(palette)
        return "swatch://palette/\(share.shareCode)"
    }

    func importPalette(code: String) async -> ColorSet? {
        // In production, would verify code with server
        // For now, simulate finding a palette
        return nil
    }

    func getSharedPalette(_ shareCode: String) -> ColorSet? {
        guard let share = sharedLinks.first(where: { $0.shareCode == shareCode }) else {
            return nil
        }
        return mySharedPalettes.first(where: { $0.id == share.paletteId })
    }

    // MARK: - Featured & Trending

    func fetchFeaturedPalettes() async {
        // Simulate fetching featured palettes
        featuredPalettes = generateMockPalettes(count: 6)
    }

    func fetchTrendingPalettes() async {
        // Simulate fetching trending palettes
        trendingPalettes = generateMockPalettes(count: 10)
    }

    private func generateMockPalettes(count: Int) -> [ColorSet] {
        (0..<count).map { i in
            ColorSet(
                name: "Palette \(i + 1)",
                colors: [
                    SwatchColor(hex: "#FF6B6B"),
                    SwatchColor(hex: "#4ECDC4"),
                    SwatchColor(hex: "#45B7D1"),
                    SwatchColor(hex: "#96CEB4"),
                    SwatchColor(hex: "#FFEAA7")
                ],
                category: ColorCategory.allCases.randomElement()!,
                authorName: "Designer \(i)",
                downloadCount: Int.random(in: 100...10000),
                rating: Double.random(in: 3.5...5.0)
            )
        }
    }

    // MARK: - Accessibility

    func checkAccessibility(foreground: String, background: String) -> AccessibilityCheck {
        // Simplified contrast calculation
        let contrast = calculateContrast(foreground, background)
        return AccessibilityCheck(
            foregroundColor: foreground,
            backgroundColor: background,
            contrastRatio: contrast,
            wcagAA: contrast >= 4.5,
            wcagAAA: contrast >= 7.0,
            wcagAALarge: contrast >= 3.0,
            wcagAAALarge: contrast >= 4.5,
            recommendation: contrast < 4.5 ? "Increase contrast for better readability" : nil
        )
    }

    private func calculateContrast(_ hex1: String, _ hex2: String) -> Double {
        // Simplified luminance calculation
        let l1 = calculateLuminance(hex1)
        let l2 = calculateLuminance(hex2)
        let lighter = max(l1, l2)
        let darker = min(l1, l2)
        return (lighter + 0.05) / (darker + 0.05)
    }

    private func calculateLuminance(_ hex: String) -> Double {
        let r = Double(Int(hex.dropFirst().prefix(2), radix: 16) ?? 0) / 255
        let g = Double(Int(hex.dropFirst(3).prefix(2), radix: 16) ?? 0) / 255
        let b = Double(Int(hex.dropFirst(5).prefix(2), radix: 16) ?? 0) / 255
        return 0.2126 * r + 0.7152 * g + 0.0722 * b
    }

    // MARK: - Color Blindness

    func simulateColorBlindness(_ hex: String, type: ColorBlindnessType) -> String {
        // Simplified simulation - in production would use proper matrices
        // For now, just return a slightly adjusted color
        return adjustForColorBlindness(hex, type: type)
    }

    private func adjustForColorBlindness(_ hex: String, type: ColorBlindnessType) -> String {
        // Placeholder - actual implementation would use color blindness simulation matrices
        return hex
    }

    // MARK: - Export

    func exportPalette(_ palette: ColorSet, format: ColorExportFormat) -> URL? {
        let content: String

        switch format {
        case .hex:
            content = palette.colors.map { $0.hex }.joined(separator: "\n")
        case .rgb:
            content = palette.colors.map { $0.toRGBString() }.joined(separator: "\n")
        case .swift, .swiftui:
            content = palette.colors.map { "Color(hex: \"\($0.hex)\")" }.joined(separator: "\n")
        case .css:
            content = palette.colors.enumerated().map { " --color-\($0.offset + 1): \($0.element.hex);" }.joined(separator: "\n")
        case .json:
            if let data = try? JSONEncoder().encode(palette),
               let str = String(data: data, encoding: .utf8) {
                content = str
            } else { return nil }
        default:
            content = palette.colors.map { $0.hex }.joined(separator: ", ")
        }

        let tempDir = FileManager.default.temporaryDirectory
        let fileName = "\(palette.name.replacingOccurrences(of: " ", with: "_")).\(format.fileExtension)"
        let fileURL = tempDir.appendingPathComponent(fileName)

        do {
            try content.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            return nil
        }
    }

    // MARK: - Persistence

    private func saveSharedPalettes() {
        if let data = try? JSONEncoder().encode(mySharedPalettes) {
            UserDefaults.standard.set(data, forKey: sharedKey)
        }
    }

    private func loadSharedPalettes() {
        if let data = UserDefaults.standard.data(forKey: sharedKey),
           let palettes = try? JSONDecoder().decode([ColorSet].self, from: data) {
            mySharedPalettes = palettes
        }
    }

    private func saveSharedLinks() {
        if let data = try? JSONEncoder().encode(sharedLinks) {
            UserDefaults.standard.set(data, forKey: linksKey)
        }
    }

    private func loadSharedLinks() {
        if let data = UserDefaults.standard.data(forKey: linksKey),
           let links = try? JSONDecoder().decode([ColorPaletteShare].self, from: data) {
            sharedLinks = links
        }
    }
}

// MARK: - SwatchColor Extension

extension SwatchColor {
    func toRGBString() -> String {
        let rgb = toRGB()
        return "rgb(\(rgb.r), \(rgb.g), \(rgb.b))"
    }

    func toRGB() -> (r: Int, g: Int, b: Int) {
        var hex = self.hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        if hex.count == 6 {
            hex = "FF" + hex // Add alpha
        }

        let r = Int(hex.dropFirst().prefix(2), radix: 16) ?? 0
        let g = Int(hex.dropFirst(3).prefix(2), radix: 16) ?? 0
        let b = Int(hex.dropFirst(5).prefix(2), radix: 16) ?? 0
        return (r, g, b)
    }
}
