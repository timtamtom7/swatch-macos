import Foundation

struct ColorHistoryEntry: Identifiable, Codable {
    let id: UUID
    let color: SwatchColor
    let timestamp: Date
    let source: ColorSource
}

enum ColorSource: String, Codable {
    case picker
    case eyedropper
    case palette
    case import_
}

final class ColorHistoryManager {
    static let shared = ColorHistoryManager()

    private let historyKey = "colorHistory"
    private let maxEntries = 100

    private init() {}

    func addEntry(_ color: SwatchColor, source: ColorSource) {
        let entry = ColorHistoryEntry(id: UUID(), color: color, timestamp: Date(), source: source)
        var history = fetchHistory()
        history.insert(entry, at: 0)

        if history.count > maxEntries {
            history = Array(history.prefix(maxEntries))
        }

        saveHistory(history)
    }

    func fetchHistory() -> [ColorHistoryEntry] {
        guard let data = UserDefaults.standard.data(forKey: historyKey) else { return [] }
        do {
            return try JSONDecoder().decode([ColorHistoryEntry].self, from: data)
        } catch {
            return []
        }
    }

    func clearHistory() {
        UserDefaults.standard.removeObject(forKey: historyKey)
    }

    private func saveHistory(_ history: [ColorHistoryEntry]) {
        do {
            let data = try JSONEncoder().encode(history)
            UserDefaults.standard.set(data, forKey: historyKey)
        } catch {
            print("Failed to save color history: \(error)")
        }
    }
}
