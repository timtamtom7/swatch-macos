import Foundation

enum ColorConverter {

    static func hexToRGB(_ hex: String) -> (r: Int, g: Int, b: Int) {
        var clean = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if clean.hasPrefix("#") {
            clean.removeFirst()
        }
        if clean.count == 3 {
            clean = clean.map { "\($0)\($0)" }.joined()
        }
        guard clean.count == 6,
              let intVal = Int(clean, radix: 16) else {
            return (0, 0, 0)
        }
        return (
            r: (intVal >> 16) & 0xFF,
            g: (intVal >> 8) & 0xFF,
            b: intVal & 0xFF
        )
    }

    static func rgbToHex(_ rgb: (r: Int, g: Int, b: Int)) -> String {
        let r = max(0, min(255, rgb.r))
        let g = max(0, min(255, rgb.g))
        let b = max(0, min(255, rgb.b))
        return String(format: "#%02X%02X%02X", r, g, b)
    }

    static func rgbToHSB(_ rgb: (r: Int, g: Int, b: Int)) -> (h: Double, s: Double, b: Double) {
        let r = Double(rgb.r) / 255.0
        let g = Double(rgb.g) / 255.0
        let b = Double(rgb.b) / 255.0

        let maxC = max(r, g, b)
        let minC = min(r, g, b)
        let delta = maxC - minC

        var h: Double = 0
        let s: Double = maxC == 0 ? 0 : delta / maxC
        let brightness: Double = maxC

        if delta != 0 {
            if maxC == r {
                h = (g - b) / delta
                if g < b { h += 6 }
            } else if maxC == g {
                h = 2 + (b - r) / delta
            } else {
                h = 4 + (r - g) / delta
            }
            h /= 6
            if h < 0 { h += 1 }
        }

        return (h: h * 360, s: s, b: brightness)
    }

    static func rgbToCMYK(_ rgb: (r: Int, g: Int, b: Int)) -> (c: Double, m: Double, y: Double, k: Double) {
        let r = Double(rgb.r) / 255.0
        let g = Double(rgb.g) / 255.0
        let b = Double(rgb.b) / 255.0

        let k = 1.0 - max(r, g, b)
        if k >= 1.0 {
            return (c: 0, m: 0, y: 0, k: 1.0)
        }

        let c = (1.0 - r - k) / (1.0 - k)
        let m = (1.0 - g - k) / (1.0 - k)
        let y = (1.0 - b - k) / (1.0 - k)

        return (c: c, m: m, y: y, k: k)
    }

    static func hsbToRGB(_ hsb: (h: Double, s: Double, b: Double)) -> (r: Int, g: Int, b: Int) {
        let h = hsb.h / 360.0
        let s = hsb.s
        let v = hsb.b

        if s == 0 {
            let gray = Int(v * 255)
            return (r: gray, g: gray, b: gray)
        }

        let i = Int(h * 6)
        let f = h * 6 - Double(i)
        let p = v * (1 - s)
        let q = v * (1 - f * s)
        let t = v * (1 - (1 - f) * s)

        var r, g, b: Double
        switch i % 6 {
        case 0: r = v; g = t; b = p
        case 1: r = q; g = v; b = p
        case 2: r = p; g = v; b = t
        case 3: r = p; g = q; b = v
        case 4: r = t; g = p; b = v
        case 5: r = v; g = p; b = q
        default: r = v; g = t; b = p
        }

        return (
            r: Int(r * 255),
            g: Int(g * 255),
            b: Int(b * 255)
        )
    }
}
