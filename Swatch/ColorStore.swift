import AppKit
import Foundation

@MainActor
class ColorStore: ObservableObject {
    static let shared = ColorStore()

    @Published var selectedColor: SwatchColor = SwatchColor(hex: "#4A90D9")
    @Published var colorHistory: [SwatchColor] = []

    private let historyKey = "swatch_color_history"
    private let maxHistory = 20

    private init() {
        loadHistory()
    }

    func selectColor(_ color: SwatchColor) {
        selectedColor = color
        addToHistory(color)
    }

    func addToHistory(_ color: SwatchColor) {
        colorHistory.removeAll { $0.hex == color.hex }
        colorHistory.insert(color, at: 0)
        if colorHistory.count > maxHistory {
            colorHistory = Array(colorHistory.prefix(maxHistory))
        }
        saveHistory()
    }

    func clearHistory() {
        colorHistory.removeAll()
        saveHistory()
    }

    func copyToClipboard(_ text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
    }

    private func saveHistory() {
        let hexStrings = colorHistory.map { $0.hex }
        if let data = try? JSONEncoder().encode(hexStrings) {
            UserDefaults.standard.set(data, forKey: historyKey)
        }
    }

    private func loadHistory() {
        guard let data = UserDefaults.standard.data(forKey: historyKey),
              let hexStrings = try? JSONDecoder().decode([String].self, from: data) else {
            return
        }
        colorHistory = hexStrings.map { SwatchColor(hex: $0) }
    }
}
