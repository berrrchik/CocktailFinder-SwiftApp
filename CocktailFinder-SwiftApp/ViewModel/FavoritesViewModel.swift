import Foundation

class FavoritesViewModel: ObservableObject {
    @Published var favorites: [Cocktail] = []
    
    private let favoritesService: FavoritesServiceProtocol
    
    init(favoritesService: FavoritesServiceProtocol = FavoritesService.shared) {
        self.favoritesService = favoritesService
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