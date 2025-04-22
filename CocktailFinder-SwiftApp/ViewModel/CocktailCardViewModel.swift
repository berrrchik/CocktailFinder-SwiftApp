import Foundation

class CocktailCardViewModel: ObservableObject {
    @Published var cocktail: Cocktail
    @Published var isFavorite: Bool = false
    
    internal let favoritesService: FavoritesServiceProtocol
    
    init(cocktail: Cocktail, favoritesService: FavoritesServiceProtocol = FavoritesService.shared) {
        self.cocktail = cocktail
        self.favoritesService = favoritesService
        checkIsFavorite()
    }
    
    func checkIsFavorite() {
        isFavorite = favoritesService.isFavorite(cocktail)
    }
    
    func toggleFavorite() {
        isFavorite.toggle()
        
        if isFavorite {
            favoritesService.addToFavorites(cocktail)
        } else {
            favoritesService.removeFromFavorites(cocktail)
        }
    }
} 