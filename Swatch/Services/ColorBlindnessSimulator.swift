import Foundation

/// Color blindness simulation types
enum ColorBlindnessType: String, CaseIterable, Identifiable {
    case none = "None"
    case protanopia = "Protanopia"       // Red-blind (no L cones)
    case deuteranopia = "Deuteranopia"   // Green-blind (no M cones)
    case tritanopia = "Tritanopia"       // Blue-blind (no S cones)
    case protanomaly = "Protanomaly"     // Red-weak (anomalous L cones)
    case deuteranomaly = "Deuteranomaly" // Green-weak (anomalous M cones)
    case tritanomaly = "Tritanomaly"     // Blue-weak (anomalous S cones)
    case achromatopsia = "Achromatopsia" // Total color blindness
    case achromatomaly = "Achromatomaly" // Partial color blindness

    var id: String { rawValue }

    var description: String {
        switch self {
        case .none: return "Normal color vision"
        case .protanopia: return "Red-blind (no red cones)"
        case .deuteranopia: return "Green-blind (no green cones)"
        case .tritanopia: return "Blue-blind (no blue cones)"
        case .protanomaly: return "Red-weak (reduced red sensitivity)"
        case .deuteranomaly: return "Green-weak (reduced green sensitivity)"
        case .tritanomaly: return "Blue-weak (reduced blue sensitivity)"
        case .achromatopsia: return "Total color blindness (no color perception)"
        case .achromatomaly: return "Partial color blindness (severely reduced color)"
        }
    }

    /// Matrix for simulating color vision deficiency
    /// Based on the Brettel, Viénot, and Mollon (1997) algorithm
    var simulationMatrix: [[Double]] {
        switch self {
        case .none:
            return [
                [1.0, 0.0, 0.0],
                [0.0, 1.0, 0.0],
                [0.0, 0.0, 1.0]
            ]

        case .protanopia:
            // L cones missing -> use M and S
            return [
                [0.567, 0.433, 0.0],
                [0.558, 0.442, 0.0],
                [0.0, 0.242, 0.758]
            ]

        case .deuteranopia:
            // M cones missing -> use L and S
            return [
                [0.625, 0.375, 0.0],
                [0.7, 0.3, 0.0],
                [0.0, 0.3, 0.7]
            ]

        case .tritanopia:
            // S cones missing -> use L and M
            return [
                [0.95, 0.05, 0.0],
                [0.0, 0.433, 0.567],
                [0.0, 0.475, 0.525]
            ]

        case .protanomaly:
            // L cones weak
            return [
                [0.817, 0.183, 0.0],
                [0.333, 0.667, 0.0],
                [0.0, 0.125, 0.875]
            ]

        case .deuteranomaly:
            // M cones weak (most common)
            return [
                [0.8, 0.2, 0.0],
                [0.258, 0.742, 0.0],
                [0.0, 0.142, 0.858]
            ]

        case .tritanomaly:
            // S cones weak
            return [
                [0.967, 0.033, 0.0],
                [0.0, 0.733, 0.267],
                [0.0, 0.183, 0.817]
            ]

        case .achromatopsia:
            // Grayscale
            return [
                [0.299, 0.587, 0.114],
                [0.299, 0.587, 0.114],
                [0.299, 0.587, 0.114]
            ]

        case .achromatomaly:
            // Severely reduced color
            return [
                [0.618, 0.320, 0.062],
                [0.163, 0.775, 0.062],
                [0.163, 0.320, 0.516]
            ]
        }
    }

    func simulate(_ rgb: RGB) -> RGB {
        let matrix = simulationMatrix

        let r = Double(rgb.r) / 255.0
        let g = Double(rgb.g) / 255.0
        let b = Double(rgb.b) / 255.0

        let newR = matrix[0][0] * r + matrix[0][1] * g + matrix[0][2] * b
        let newG = matrix[1][0] * r + matrix[1][1] * g + matrix[1][2] * b
        let newB = matrix[2][0] * r + matrix[2][1] * g + matrix[2][2] * b

        return RGB(
            r: Int(min(max(round(newR * 255.0), 0), 255)),
            g: Int(min(max(round(newG * 255.0), 0), 255)),
            b: Int(min(max(round(newB * 255.0), 0), 255))
        )
    }

    func simulate(_ color: SwatchColor) -> SwatchColor {
        let newRGB = simulate(color.rgb)
        return SwatchColor(rgb: newRGB)
    }
}

// MARK: - Color Blindness Simulator

final class ColorBlindnessSimulator {
    static let shared = ColorBlindnessSimulator()

    private init() {}

    /// Returns an array of simulated colors for the given color under different conditions
    func simulateColor(_ color: SwatchColor) -> [(type: ColorBlindnessType, color: SwatchColor)] {
        ColorBlindnessType.allCases.map { type in
            (type: type, color: type.simulate(color))
        }
    }

    /// Returns a preview showing how a palette would appear to someone with the given type
    func previewPalette(_ palette: ColorPalette, for type: ColorBlindnessType) -> [PaletteColor] {
        palette.colors.map { pc in
            let color = SwatchColor(hex: pc.hex)
            let simulated = type.simulate(color)
            return PaletteColor(
                id: pc.id,
                hex: simulated.hex,
                name: pc.name,
                position: pc.position
            )
        }
    }
}
