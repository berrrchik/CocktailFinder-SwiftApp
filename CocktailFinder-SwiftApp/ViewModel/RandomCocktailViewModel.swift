import Foundation

class RandomCocktailViewModel: ObservableObject {
    @Published var cocktail: Cocktail?
    @Published var isLoading: Bool = false
    @Published var error: Error?
    
    private let apiService: APIServiceProtocol
    
    init(apiService: APIServiceProtocol = APIService.shared) {
        self.apiService = apiService
        loadRandomCocktail()
    }
    
    func loadRandomCocktail() {
        isLoading = true
        error = nil
        
        Task {
            do {
                let cocktail = try await apiService.fetchRandomCocktail()
                
                let work = DispatchWorkItem {
                    self.cocktail = cocktail
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
} 