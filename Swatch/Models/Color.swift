import Foundation

// MARK: - Color Set

struct ColorSet: Identifiable, Codable {
    let id: UUID
    var name: String
    var colors: [SwatchColor]
    var category: ColorCategory
    var tags: [String]
    var createdAt: Date
    var updatedAt: Date
    var isPublic: Bool
    var authorName: String?
    var downloadCount: Int
    var rating: Double

    init(
        id: UUID = UUID(),
        name: String,
        colors: [SwatchColor] = [],
        category: ColorCategory = .custom,
        tags: [String] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        isPublic: Bool = false,
        authorName: String? = nil,
        downloadCount: Int = 0,
        rating: Double = 0
    ) {
        self.id = id
        self.name = name
        self.colors = colors
        self.category = category
        self.tags = tags
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isPublic = isPublic
        self.authorName = authorName
        self.downloadCount = downloadCount
        self.rating = rating
    }
}

enum ColorCategory: String, Codable, CaseIterable {
    case custom = "Custom"
    case palette = "Palette"
    case gradient = "Gradient"
    case material = "Material"
    case flat = "Flat UI"
    case vintage = "Vintage"
    case nature = "Nature"
    case tech = "Tech"
    case minimal = "Minimal"

    var icon: String {
        switch self {
        case .custom: return "paintbrush"
        case .palette: return "paintpalette"
        case .gradient: return "circle.lefthalf.filled"
        case .material: return "cube"
        case .flat: return "square"
        case .vintage: return "camera.filters"
        case .nature: return "leaf"
        case .tech: return "cpu"
        case .minimal: return "minus.circle"
        }
    }
}

// MARK: - Color Palette Share

struct ColorPaletteShare: Identifiable, Codable {
    let id: UUID
    var paletteId: UUID
    var shareCode: String
    var shareURL: String
    var expiresAt: Date?
    var accessCount: Int
    var createdAt: Date

    init(
        id: UUID = UUID(),
        paletteId: UUID,
        shareCode: String = UUID().uuidString.prefix(8).uppercased().description,
        shareURL: String = "",
        expiresAt: Date? = nil,
        accessCount: Int = 0,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.paletteId = paletteId
        self.shareCode = shareCode
        self.shareURL = shareURL
        self.expiresAt = expiresAt
        self.accessCount = accessCount
        self.createdAt = createdAt
    }
}

// MARK: - Export Format

enum ColorExportFormat: String, CaseIterable {
    case hex = "HEX"
    case rgb = "RGB"
    case rgba = "RGBA"
    case hsl = "HSL"
    case hsla = "HSLA"
    case swift = "Swift UIColor"
    case objc = "Obj-C"
    case css = "CSS Variables"
    case json = "JSON"
    case swiftui = "SwiftUI Color"
    case sketch = "Sketch Palette"
    case adobe = "Adobe ASE"
    case png = "PNG Swatch"

    var fileExtension: String {
        switch self {
        case .hex, .rgb, .rgba, .hsl, .hsla: return "txt"
        case .swift, .objc, .swiftui: return "swift"
        case .css: return "css"
        case .json: return "json"
        case .sketch: return "sketchpalette"
        case .adobe: return "ase"
        case .png: return "png"
        }
    }
}

// MARK: - Accessibility Check

struct AccessibilityCheck: Identifiable, Codable {
    let id: UUID
    var foregroundColor: String
    var backgroundColor: String
    var contrastRatio: Double
    var wcagAA: Bool
    var wcagAAA: Bool
    var wcagAALarge: Bool
    var wcagAAALarge: Bool
    var recommendation: String?

    init(
        id: UUID = UUID(),
        foregroundColor: String,
        backgroundColor: String,
        contrastRatio: Double,
        wcagAA: Bool = false,
        wcagAAA: Bool = false,
        wcagAALarge: Bool = false,
        wcagAAALarge: Bool = false,
        recommendation: String? = nil
    ) {
        self.id = id
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
        self.contrastRatio = contrastRatio
        self.wcagAA = wcagAA
        self.wcagAAA = wcagAAA
        self.wcagAALarge = wcagAALarge
        self.wcagAAALarge = wcagAAALarge
        self.recommendation = recommendation
    }
}

// MARK: - Color Harmony Rule

enum ColorHarmonyRule: String, CaseIterable, Codable, Identifiable {
    case complementary = "Complementary"
    case analogous = "Analogous"
    case triadic = "Triadic"
    case tetradic = "Tetradic"
    case splitComplementary = "Split Complementary"
    case monochromatic = "Monochromatic"

    var id: String { rawValue }

    var description: String {
        switch self {
        case .complementary: return "Colors opposite on the color wheel"
        case .analogous: return "Colors adjacent on the color wheel"
        case .triadic: return "Three colors equally spaced"
        case .tetradic: return "Four colors in two complementary pairs"
        case .splitComplementary: return "Base color with two adjacent to its complement"
        case .monochromatic: return "Single hue with varying saturation/lightness"
        }
    }

    var icon: String {
        switch self {
        case .complementary: return "arrow.left.arrow.right"
        case .analogous: return "arrow.right"
        case .triadic: return "triangle"
        case .tetradic: return "square"
        case .splitComplementary: return "arrow.branch"
        case .monochromatic: return "circle.grid.2x2"
        }
    }
}

// MARK: - Color Designer

struct ColorDesigner: Identifiable, Codable {
    let id: UUID
    var name: String
    var palettes: [ColorSet]
    var followers: Int
    var isVerified: Bool
    var website: String?
    var twitter: String?

    init(
        id: UUID = UUID(),
        name: String,
        palettes: [ColorSet] = [],
        followers: Int = 0,
        isVerified: Bool = false,
        website: String? = nil,
        twitter: String? = nil
    ) {
        self.id = id
        self.name = name
        self.palettes = palettes
        self.followers = followers
        self.isVerified = isVerified
        self.website = website
        self.twitter = twitter
    }
}
