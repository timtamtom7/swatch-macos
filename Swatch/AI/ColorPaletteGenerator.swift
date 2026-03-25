import Foundation
import AppKit

/// AI-powered color palette generator for Swatch
final class ColorPaletteGenerator {
    static let shared = ColorPaletteGenerator()
    
    private init() {}
    
    // MARK: - Palette Generation
    
    enum PaletteType: String, CaseIterable {
        case complementary
        case analogous
        case triadic
        case tetradic
        case splitComplementary
        case monochromatic
        case warm
        case cool
        case sunset
        case ocean
        case forest
        case pastel
    }
    
    struct ColorPalette: Identifiable {
        let id = UUID()
        let name: String
        let colors: [NSColor]
        let type: PaletteType
    }
    
    /// Generate a harmonious palette based on a seed color
    func generatePalette(from seedColor: NSColor, type: PaletteType) -> ColorPalette {
        let hsb = seedColor.hsbComponents
        let baseHue = hsb.hue
        let baseSat = hsb.saturation
        let baseBri = hsb.brightness
        
        var colors: [NSColor] = []
        
        switch type {
        case .complementary:
            colors = generateComplementary(baseHue: baseHue, baseSat: baseSat, baseBri: baseBri)
            
        case .analogous:
            colors = generateAnalogous(baseHue: baseHue, baseSat: baseSat, baseBri: baseBri)
            
        case .triadic:
            colors = generateTriadic(baseHue: baseHue, baseSat: baseSat, baseBri: baseBri)
            
        case .tetradic:
            colors = generateTetradic(baseHue: baseHue, baseSat: baseSat, baseBri: baseBri)
            
        case .splitComplementary:
            colors = generateSplitComplementary(baseHue: baseHue, baseSat: baseSat, baseBri: baseBri)
            
        case .monochromatic:
            colors = generateMonochromatic(baseHue: baseHue, baseSat: baseSat, baseBri: baseBri)
            
        case .warm:
            colors = generateWarmPalette(baseHue: baseHue, baseSat: baseSat, baseBri: baseBri)
            
        case .cool:
            colors = generateCoolPalette(baseHue: baseHue, baseSat: baseSat, baseBri: baseBri)
            
        case .sunset:
            colors = generateSunsetPalette(baseHue: baseHue, baseSat: baseSat, baseBri: baseBri)
            
        case .ocean:
            colors = generateOceanPalette(baseHue: baseHue, baseSat: baseSat, baseBri: baseBri)
            
        case .forest:
            colors = generateForestPalette(baseHue: baseHue, baseSat: baseSat, baseBri: baseBri)
            
        case .pastel:
            colors = generatePastelPalette(baseHue: baseHue, baseSat: baseSat, baseBri: baseBri)
        }
        
        return ColorPalette(name: type.rawValue.capitalized, colors: colors, type: type)
    }
    
    // MARK: - Palette Algorithms
    
    private func generateComplementary(baseHue: CGFloat, baseSat: CGFloat, baseBri: CGFloat) -> [NSColor] {
        let compHue = (baseHue + 0.5).truncatingRemainder(dividingBy: 1.0)
        return [
            NSColor(hue: baseHue, saturation: baseSat, brightness: baseBri, alpha: 1.0),
            NSColor(hue: baseHue, saturation: baseSat * 0.7, brightness: min(1.0, baseBri + 0.1), alpha: 1.0),
            NSColor(hue: baseHue, saturation: baseSat * 0.3, brightness: baseBri, alpha: 1.0),
            NSColor(hue: compHue, saturation: baseSat, brightness: baseBri, alpha: 1.0),
            NSColor(hue: compHue, saturation: baseSat * 0.7, brightness: min(1.0, baseBri + 0.1), alpha: 1.0)
        ]
    }
    
    private func generateAnalogous(baseHue: CGFloat, baseSat: CGFloat, baseBri: CGFloat) -> [NSColor] {
        return [
            NSColor(hue: (baseHue - 0.05).truncatingRemainder(dividingBy: 1.0), saturation: baseSat, brightness: baseBri, alpha: 1.0),
            NSColor(hue: baseHue, saturation: baseSat, brightness: baseBri, alpha: 1.0),
            NSColor(hue: (baseHue + 0.03).truncatingRemainder(dividingBy: 1.0), saturation: baseSat, brightness: baseBri, alpha: 1.0),
            NSColor(hue: (baseHue + 0.05).truncatingRemainder(dividingBy: 1.0), saturation: baseSat * 0.8, brightness: baseBri, alpha: 1.0),
            NSColor(hue: (baseHue + 0.08).truncatingRemainder(dividingBy: 1.0), saturation: baseSat * 0.6, brightness: baseBri, alpha: 1.0)
        ]
    }
    
    private func generateTriadic(baseHue: CGFloat, baseSat: CGFloat, baseBri: CGFloat) -> [NSColor] {
        let hue2 = (baseHue + 1.0/3.0).truncatingRemainder(dividingBy: 1.0)
        let hue3 = (baseHue + 2.0/3.0).truncatingRemainder(dividingBy: 1.0)
        return [
            NSColor(hue: baseHue, saturation: baseSat, brightness: baseBri, alpha: 1.0),
            NSColor(hue: baseHue, saturation: baseSat * 0.5, brightness: min(1.0, baseBri + 0.1), alpha: 1.0),
            NSColor(hue: hue2, saturation: baseSat, brightness: baseBri, alpha: 1.0),
            NSColor(hue: hue2, saturation: baseSat * 0.5, brightness: min(1.0, baseBri + 0.1), alpha: 1.0),
            NSColor(hue: hue3, saturation: baseSat, brightness: baseBri, alpha: 1.0)
        ]
    }
    
    private func generateTetradic(baseHue: CGFloat, baseSat: CGFloat, baseBri: CGFloat) -> [NSColor] {
        return [
            NSColor(hue: baseHue, saturation: baseSat, brightness: baseBri, alpha: 1.0),
            NSColor(hue: (baseHue + 0.25).truncatingRemainder(dividingBy: 1.0), saturation: baseSat, brightness: baseBri, alpha: 1.0),
            NSColor(hue: (baseHue + 0.5).truncatingRemainder(dividingBy: 1.0), saturation: baseSat, brightness: baseBri, alpha: 1.0),
            NSColor(hue: (baseHue + 0.75).truncatingRemainder(dividingBy: 1.0), saturation: baseSat, brightness: baseBri, alpha: 1.0),
            NSColor(hue: baseHue, saturation: baseSat * 0.5, brightness: min(1.0, baseBri + 0.15), alpha: 1.0)
        ]
    }
    
    private func generateSplitComplementary(baseHue: CGFloat, baseSat: CGFloat, baseBri: CGFloat) -> [NSColor] {
        let comp1 = (baseHue + 0.5 - 0.05).truncatingRemainder(dividingBy: 1.0)
        let comp2 = (baseHue + 0.5 + 0.05).truncatingRemainder(dividingBy: 1.0)
        return [
            NSColor(hue: baseHue, saturation: baseSat, brightness: baseBri, alpha: 1.0),
            NSColor(hue: baseHue, saturation: baseSat * 0.6, brightness: min(1.0, baseBri + 0.1), alpha: 1.0),
            NSColor(hue: comp1, saturation: baseSat, brightness: baseBri, alpha: 1.0),
            NSColor(hue: comp2, saturation: baseSat, brightness: baseBri, alpha: 1.0),
            NSColor(hue: comp1, saturation: baseSat * 0.6, brightness: min(1.0, baseBri + 0.1), alpha: 1.0)
        ]
    }
    
    private func generateMonochromatic(baseHue: CGFloat, baseSat: CGFloat, baseBri: CGFloat) -> [NSColor] {
        let variations: [(CGFloat, CGFloat)] = [
            (0.3, 0.4),
            (0.5, 0.6),
            (0.7, 0.8),
            (0.85, 0.9),
            (1.0, 1.0)
        ]
        return variations.map { sat, bri in
            NSColor(hue: baseHue, saturation: baseSat * sat, brightness: baseBri * bri, alpha: 1.0)
        }
    }
    
    private func generateWarmPalette(baseHue: CGFloat, baseSat: CGFloat, baseBri: CGFloat) -> [NSColor] {
        // Shift towards warm hues (red-orange-yellow range)
        let warmHue = baseHue < 0.1 || baseHue > 0.9 ? baseHue : 0.05 // Default to orange-red
        return [
            NSColor(hue: warmHue, saturation: baseSat, brightness: baseBri, alpha: 1.0),
            NSColor(hue: (warmHue + 0.08).truncatingRemainder(dividingBy: 1.0), saturation: baseSat * 0.8, brightness: min(1.0, baseBri + 0.05), alpha: 1.0),
            NSColor(hue: (warmHue + 0.15).truncatingRemainder(dividingBy: 1.0), saturation: baseSat * 0.6, brightness: min(1.0, baseBri + 0.1), alpha: 1.0),
            NSColor(hue: (warmHue - 0.02).truncatingRemainder(dividingBy: 1.0), saturation: baseSat * 0.9, brightness: baseBri * 0.8, alpha: 1.0),
            NSColor(hue: (warmHue + 0.03).truncatingRemainder(dividingBy: 1.0), saturation: baseSat * 0.5, brightness: baseBri * 0.9, alpha: 1.0)
        ]
    }
    
    private func generateCoolPalette(baseHue: CGFloat, baseSat: CGFloat, baseBri: CGFloat) -> [NSColor] {
        // Shift towards cool hues (blue-cyan range)
        let coolHue: CGFloat
        if baseHue >= 0.5 && baseHue <= 0.7 {
            coolHue = baseHue
        } else {
            coolHue = 0.6 // Default to blue
        }
        return [
            NSColor(hue: coolHue, saturation: baseSat, brightness: baseBri, alpha: 1.0),
            NSColor(hue: (coolHue + 0.05).truncatingRemainder(dividingBy: 1.0), saturation: baseSat * 0.8, brightness: min(1.0, baseBri + 0.05), alpha: 1.0),
            NSColor(hue: (coolHue - 0.05).truncatingRemainder(dividingBy: 1.0), saturation: baseSat * 0.7, brightness: min(1.0, baseBri + 0.1), alpha: 1.0),
            NSColor(hue: (coolHue + 0.1).truncatingRemainder(dividingBy: 1.0), saturation: baseSat * 0.6, brightness: baseBri * 0.9, alpha: 1.0),
            NSColor(hue: (coolHue - 0.1).truncatingRemainder(dividingBy: 1.0), saturation: baseSat * 0.5, brightness: baseBri * 0.95, alpha: 1.0)
        ]
    }
    
    private func generateSunsetPalette(baseHue: CGFloat, baseSat: CGFloat, baseBri: CGFloat) -> [NSColor] {
        // Sunset palette: yellow -> orange -> red -> purple -> dark blue
        return [
            NSColor(hue: 0.12, saturation: 0.9, brightness: 1.0, alpha: 1.0), // Yellow
            NSColor(hue: 0.08, saturation: 0.95, brightness: 0.95, alpha: 1.0), // Orange
            NSColor(hue: 0.02, saturation: 0.9, brightness: 0.9, alpha: 1.0),  // Red-orange
            NSColor(hue: 0.78, saturation: 0.7, brightness: 0.7, alpha: 1.0),  // Purple
            NSColor(hue: 0.65, saturation: 0.5, brightness: 0.5, alpha: 1.0)   // Dark blue
        ]
    }
    
    private func generateOceanPalette(baseHue: CGFloat, baseSat: CGFloat, baseBri: CGFloat) -> [NSColor] {
        // Ocean palette: deep blue -> teal -> cyan -> light blue -> white
        return [
            NSColor(hue: 0.6, saturation: 0.8, brightness: 0.4, alpha: 1.0),  // Deep blue
            NSColor(hue: 0.52, saturation: 0.7, brightness: 0.5, alpha: 1.0), // Teal
            NSColor(hue: 0.48, saturation: 0.6, brightness: 0.7, alpha: 1.0),  // Cyan
            NSColor(hue: 0.55, saturation: 0.4, brightness: 0.85, alpha: 1.0), // Light blue
            NSColor(hue: 0.58, saturation: 0.2, brightness: 0.95, alpha: 1.0)  // Pale blue
        ]
    }
    
    private func generateForestPalette(baseHue: CGFloat, baseSat: CGFloat, baseBri: CGFloat) -> [NSColor] {
        // Forest palette: dark green -> green -> light green -> brown -> cream
        return [
            NSColor(hue: 0.33, saturation: 0.6, brightness: 0.25, alpha: 1.0), // Dark green
            NSColor(hue: 0.35, saturation: 0.5, brightness: 0.4, alpha: 1.0),  // Green
            NSColor(hue: 0.28, saturation: 0.4, brightness: 0.55, alpha: 1.0),  // Light green
            NSColor(hue: 0.07, saturation: 0.5, brightness: 0.35, alpha: 1.0), // Brown
            NSColor(hue: 0.1, saturation: 0.2, brightness: 0.85, alpha: 1.0)    // Cream
        ]
    }
    
    private func generatePastelPalette(baseHue: CGFloat, baseSat: CGFloat, baseBri: CGFloat) -> [NSColor] {
        // Pastel: desaturated and lightened variations
        return [
            NSColor(hue: baseHue, saturation: baseSat * 0.4, brightness: baseBri * 0.9 + 0.1, alpha: 1.0),
            NSColor(hue: (baseHue + 0.1).truncatingRemainder(dividingBy: 1.0), saturation: baseSat * 0.35, brightness: baseBri * 0.85 + 0.1, alpha: 1.0),
            NSColor(hue: (baseHue + 0.2).truncatingRemainder(dividingBy: 1.0), saturation: baseSat * 0.3, brightness: baseBri * 0.8 + 0.15, alpha: 1.0),
            NSColor(hue: (baseHue + 0.3).truncatingRemainder(dividingBy: 1.0), saturation: baseSat * 0.25, brightness: baseBri * 0.75 + 0.2, alpha: 1.0),
            NSColor(hue: (baseHue + 0.4).truncatingRemainder(dividingBy: 1.0), saturation: baseSat * 0.2, brightness: baseBri * 0.7 + 0.25, alpha: 1.0)
        ]
    }
}

// MARK: - NSColor Extension

extension NSColor {
    var hsbComponents: (hue: CGFloat, saturation: CGFloat, brightness: CGFloat) {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        return (hue, saturation, brightness)
    }
}
