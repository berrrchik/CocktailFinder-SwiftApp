import Foundation

class FavoritesViewModel: ObservableObject {
    @Published var favorites: [Cocktail] = []
    
    private let favoritesService = FavoritesService.shared
    
    init() {
        loadFavorites()
    }
    
    func loadFavorites() {
        favorites = favoritesService.getFavorites()
    }
    
    func removeFavorite(_ cocktail: Cocktail) {
        favoritesService.removeFromFavorites(cocktail)
        loadFavorites()
    }
    
    func isFavoriteEmpty() -> Bool {
        return favorites.isEmpty
    }
} 