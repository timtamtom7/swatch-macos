import Foundation
import SwiftUI

struct ExportService {
    static func exportPalette(_ palette: ColorPalette, format: ExportFormat) -> String {
        switch format {
        case .json:
            return exportJSON(palette)
        case .swift:
            return exportSwift(palette)
        case .css:
            return exportCSS(palette)
        case .jsonPalette:
            return exportJSONPalette(palette)
        }
    }

    private static func exportJSON(_ palette: ColorPalette) -> String {
        let colors = palette.colors.map { c -> [String: Any] in
            [
                "name": c.name,
                "hex": c.hexString,
                "rgb": c.rgbString,
                "hsl": c.hslString
            ]
        }
        let dict: [String: Any] = [
            "name": palette.name,
            "colors": colors
        ]
        if let data = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted),
           let str = String(data: data, encoding: .utf8) {
            return str
        }
        return "{}"
    }

    private static func exportSwift(_ palette: ColorPalette) -> String {
        var output = "import SwiftUI\n\nextension Color {\n"
        for color in palette.colors {
            let name = color.swiftName
            output += "    static let \(name) = Color(hex: \"\(color.hexString)\")\n"
        }
        output += "}\n"
        return output
    }

    private static func exportCSS(_ palette: ColorPalette) -> String {
        var output = ":root {\n"
        for color in palette.colors {
            let name = color.cssName
            output += "    --\(name): \(color.hexString);\n"
        }
        output += "}\n"
        return output
    }

    private static func exportJSONPalette(_ palette: ColorPalette) -> String {
        var output = "{\n  \"colors\": [\n"
        for (i, color) in palette.colors.enumerated() {
            output += "    {\"hex\": \"\(color.hexString)\", \"name\": \"\(color.name)\"}"
            if i < palette.colors.count - 1 {
                output += ","
            }
            output += "\n"
        }
        output += "  ]\n}\n"
        return output
    }
}

extension SwatchColor {
    var swiftName: String {
        name.lowercased()
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "_")
            .filter { $0.isLetter || $0.isNumber || $0 == "_" }
    }

    var cssName: String {
        name.lowercased()
            .replacingOccurrences(of: " ", with: "-")
            .filter { $0.isLetter || $0.isNumber || $0 == "-" }
    }
}

enum ExportFormat: String, CaseIterable {
    case json = "JSON"
    case swift = "Swift"
    case css = "CSS"
    case jsonPalette = "Palette JSON"
}
