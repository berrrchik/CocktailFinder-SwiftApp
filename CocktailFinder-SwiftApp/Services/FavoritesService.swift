import Foundation

protocol FavoritesServiceProtocol {
    func addToFavorites(_ cocktail: Cocktail)
    func removeFromFavorites(_ cocktail: Cocktail)
    func isFavorite(_ cocktail: Cocktail) -> Bool
    func getFavorites() -> [Cocktail]
}

class FavoritesService: FavoritesServiceProtocol {
    static let shared = FavoritesService()
    private let favoritesKey = "favoriteCocktails"
    
    private init() {}
    
    func addToFavorites(_ cocktail: Cocktail) {
        var favorites = getFavorites()
        if !favorites.contains(where: { $0.id == cocktail.id }) {
            favorites.append(cocktail)
            saveFavorites(favorites)
        }
    }
    
    func removeFromFavorites(_ cocktail: Cocktail) {
        var favorites = getFavorites()
        favorites.removeAll { $0.id == cocktail.id }
        saveFavorites(favorites)
    }
    
    func isFavorite(_ cocktail: Cocktail) -> Bool {
        let favorites = getFavorites()
        return favorites.contains { $0.id == cocktail.id }
    }
    
    func getFavorites() -> [Cocktail] {
        guard let data = UserDefaults.standard.data(forKey: favoritesKey) else {
            return []
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode([Cocktail].self, from: data)
        } catch {
            print("Ошибка при чтении избранных коктейлей: \(error)")
            return []
        }
    }
    
    private func saveFavorites(_ cocktails: [Cocktail]) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(cocktails)
            UserDefaults.standard.set(data, forKey: favoritesKey)
        } catch {
            print("Ошибка при сохранении избранных коктейлей: \(error)")
        }
    }
} 