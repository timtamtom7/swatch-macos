import Foundation

/// Manages favorite colors for Swatch
final class FavoritesManager {
    static let shared = FavoritesManager()
    
    private let favoritesKey = "favoriteColors"
    private let maxFavorites = 20
    
    private init() {}
    
    func fetchFavorites() -> [SwatchColor] {
        guard let data = UserDefaults.standard.data(forKey: favoritesKey),
              let favorites = try? JSONDecoder().decode([SwatchColor].self, from: data) else {
            return []
        }
        return favorites
    }
    
    func addFavorite(_ color: SwatchColor) {
        var favorites = fetchFavorites()
        
        // Remove if already exists
        favorites.removeAll { $0.hex.uppercased() == color.hex.uppercased() }
        
        // Add at beginning
        favorites.insert(color, at: 0)
        
        // Trim to max
        if favorites.count > maxFavorites {
            favorites = Array(favorites.prefix(maxFavorites))
        }
        
        saveFavorites(favorites)
    }
    
    func removeFavorite(_ color: SwatchColor) {
        var favorites = fetchFavorites()
        favorites.removeAll { $0.hex.uppercased() == color.hex.uppercased() }
        saveFavorites(favorites)
    }
    
    func isFavorite(_ color: SwatchColor) -> Bool {
        return fetchFavorites().contains { $0.hex.uppercased() == color.hex.uppercased() }
    }
    
    private func saveFavorites(_ favorites: [SwatchColor]) {
        if let data = try? JSONEncoder().encode(favorites) {
            UserDefaults.standard.set(data, forKey: favoritesKey)
        }
    }
}
