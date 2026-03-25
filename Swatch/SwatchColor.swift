import AppKit
import Foundation

struct RGB: Hashable, Codable {
    var r: Int; var g: Int; var b: Int
}

struct HSB: Codable {
    var h: Double; var s: Double; var b: Double
}

struct CMYK: Codable {
    var c: Double; var m: Double; var y: Double; var k: Double
}

struct SwatchColor: Identifiable, Codable {
    let id: UUID
    var hex: String
    var name: String?
    var createdAt: Date

    var rgb: RGB
    var hsb: HSB
    var cmyk: CMYK

    init(hex: String) {
        self.id = UUID()
        self.hex = hex.uppercased()
        self.createdAt = Date()
        self.name = nil
        let rgbVal = ColorConverter.hexToRGB(hex)
        self.rgb = RGB(r: rgbVal.r, g: rgbVal.g, b: rgbVal.b)
        let hsbVal = ColorConverter.rgbToHSB(rgbVal)
        self.hsb = HSB(h: hsbVal.h, s: hsbVal.s, b: hsbVal.b)
        let cmykVal = ColorConverter.rgbToCMYK(rgbVal)
        self.cmyk = CMYK(c: cmykVal.c, m: cmykVal.m, y: cmykVal.y, k: cmykVal.k)
    }

    init(nsColor: NSColor) {
        let converted = nsColor.usingColorSpace(.sRGB) ?? nsColor
        self.id = UUID()
        self.createdAt = Date()
        self.name = nil
        let r = Int(round(converted.redComponent * 255))
        let g = Int(round(converted.greenComponent * 255))
        let b = Int(round(converted.blueComponent * 255))
        self.rgb = RGB(r: r, g: g, b: b)
        self.hex = ColorConverter.rgbToHex((r: r, g: g, b: b))
        let hsbVal = ColorConverter.rgbToHSB((r: r, g: g, b: b))
        self.hsb = HSB(h: hsbVal.h, s: hsbVal.s, b: hsbVal.b)
        let cmykVal = ColorConverter.rgbToCMYK((r: r, g: g, b: b))
        self.cmyk = CMYK(c: cmykVal.c, m: cmykVal.m, y: cmykVal.y, k: cmykVal.k)
    }

    init(rgb: RGB) {
        self.id = UUID()
        self.createdAt = Date()
        self.name = nil
        self.rgb = rgb
        self.hex = ColorConverter.rgbToHex((r: rgb.r, g: rgb.g, b: rgb.b))
        let hsbVal = ColorConverter.rgbToHSB((r: rgb.r, g: rgb.g, b: rgb.b))
        self.hsb = HSB(h: hsbVal.h, s: hsbVal.s, b: hsbVal.b)
        let cmykVal = ColorConverter.rgbToCMYK((r: rgb.r, g: rgb.g, b: rgb.b))
        self.cmyk = CMYK(c: cmykVal.c, m: cmykVal.m, y: cmykVal.y, k: cmykVal.k)
    }

    var nsColor: NSColor {
        NSColor(
            red: CGFloat(rgb.r) / 255.0,
            green: CGFloat(rgb.g) / 255.0,
            blue: CGFloat(rgb.b) / 255.0,
            alpha: 1.0
        )
    }

    var swiftUIColor: String {
        String(format: "Color(red:%.2f, green:%.2f, blue:%.2f)",
               Double(rgb.r) / 255.0,
               Double(rgb.g) / 255.0,
               Double(rgb.b) / 255.0)
    }

    var nsColorString: String {
        String(format: "NSColor(red:%.2f, green:%.2f, blue:%.2f, alpha:1.0)",
               Double(rgb.r) / 255.0,
               Double(rgb.g) / 255.0,
               Double(rgb.b) / 255.0)
    }

    var rgbString: String {
        "rgb(\(rgb.r), \(rgb.g), \(rgb.b))"
    }

    var hsbString: String {
        String(format: "hsb(%.0f\u{00B0}, %.0f%%, %.0f%%)",
               hsb.h, hsb.s * 100, hsb.b * 100)
    }

    var cmykString: String {
        String(format: "cmyk(%.0f%%, %.0f%%, %.0f%%, %.0f%%)",
               cmyk.c * 100, cmyk.m * 100, cmyk.y * 100, cmyk.k * 100)
    }

    // MARK: - Initializers

    init(hue: Double, saturation: Double, brightness: Double) {
        self.id = UUID()
        self.createdAt = Date()
        self.name = nil
        let rgbVal = ColorConverter.hsbToRGB((h: hue, s: saturation, b: brightness))
        self.rgb = RGB(r: rgbVal.r, g: rgbVal.g, b: rgbVal.b)
        self.hsb = HSB(h: hue, s: saturation, b: brightness)
        let cmykVal = ColorConverter.rgbToCMYK(rgbVal)
        self.cmyk = CMYK(c: cmykVal.c, m: cmykVal.m, y: cmykVal.y, k: cmykVal.k)
        self.hex = ColorConverter.rgbToHex(rgbVal)
    }

    // MARK: - Relative Luminance (WCAG)

    var relativeLuminance: Double {
        let r = linearize(Double(rgb.r) / 255.0)
        let g = linearize(Double(rgb.g) / 255.0)
        let b = linearize(Double(rgb.b) / 255.0)
        return 0.2126 * r + 0.7152 * g + 0.0722 * b
    }

    private func linearize(_ value: Double) -> Double {
        if value <= 0.03928 {
            return value / 12.92
        } else {
            return pow((value + 0.055) / 1.055, 2.4)
        }
    }
}
