import Foundation
import SwiftUI

struct WidgetData {
    var favoriteColors: [SwatchColor]
    var recentColors: [SwatchColor]

    init() {
        favoriteColors = []
        recentColors = []
    }

    static func load() -> WidgetData {
        var data = WidgetData()
        data.favoriteColors = FavoritesManager.shared.fetchFavorites()
        data.recentColors = ColorHistoryManager.shared.fetchHistory().prefix(5).map { $0.color }
        return data
    }
}

struct WidgetColorView: View {
    let color: SwatchColor

    var body: some View {
        VStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(
                    red: Double(color.red) / 255,
                    green: Double(color.green) / 255,
                    blue: Double(color.blue) / 255
                ))
                .frame(width: 44, height: 44)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )

            Text(color.hexString)
                .font(.system(size: 9, design: .monospaced))
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
    }
}
