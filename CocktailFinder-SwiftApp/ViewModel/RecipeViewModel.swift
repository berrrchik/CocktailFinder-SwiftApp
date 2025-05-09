import Foundation

class RecipeViewModel: ObservableObject {
    @Published var cocktail: Cocktail?
    @Published var isLoading: Bool = false
    @Published var error: Error?
    @Published var isFavorite: Bool = false
    
    private let apiService: APIServiceProtocol
    private let favoritesService: FavoritesServiceProtocol
    private let drinkId: String?
    
    init(drinkId: String, 
         apiService: APIServiceProtocol = APIService.shared,
         favoritesService: FavoritesServiceProtocol = FavoritesService.shared) {
        self.drinkId = drinkId
        self.apiService = apiService
        self.favoritesService = favoritesService
        self.cocktail = nil
        loadCocktailData()
    }
    
    init(cocktail: Cocktail,
         favoritesService: FavoritesServiceProtocol = FavoritesService.shared) {
        self.drinkId = nil
        self.cocktail = cocktail
        self.isLoading = false
        self.apiService = APIService.shared
        self.favoritesService = favoritesService
        
        self.isFavorite = favoritesService.isFavorite(cocktail)
    }
    
    func loadCocktailData() {
        if cocktail != nil { return }
        
        // Если нет ID коктейля, ничего не делаем
        guard let drinkId = drinkId else { return }
        
        isLoading = true
        error = nil
        
        Task {
            do {
                let cocktail = try await apiService.fetchCocktailById(drinkId)
                
                let work = DispatchWorkItem {
                    self.cocktail = cocktail
                    
                    self.isFavorite = self.favoritesService.isFavorite(cocktail)
                    self.isLoading = false
                }
                DispatchQueue.main.async(execute: work)
            } catch {
                let errorWork = DispatchWorkItem {
                    self.error = error
                    self.isLoading = false
                }
                DispatchQueue.main.async(execute: errorWork)
            }
        }
    }
    
    func toggleFavorite() {
        guard let cocktail = cocktail else { return }
        
        isFavorite.toggle()
        
        if isFavorite {
            favoritesService.addToFavorites(cocktail)
        } else {
            favoritesService.removeFromFavorites(cocktail)
        }
    }
} 
