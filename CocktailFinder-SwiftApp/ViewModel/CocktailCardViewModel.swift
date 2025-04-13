import Foundation

class CocktailCardViewModel: ObservableObject {
    @Published var cocktail: Cocktail
    @Published var isFavorite: Bool = false
    
    private let favoritesService = FavoritesService.shared
    
    init(cocktail: Cocktail) {
        self.cocktail = cocktail
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