import Foundation
import Combine

class SearchViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var popularCocktails: [Cocktail] = []
    @Published var searchResults: [Cocktail] = []
    @Published var isLoading: Bool = false
    @Published var error: Error? = nil
    @Published var hasSearched: Bool = false
    @Published var isSearchBarFocused: Bool = false
    @Published var selectedLetter: String? = nil
    
    private let apiService: APIServiceProtocol
    private let cacheService: CocktailCacheServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(apiService: APIServiceProtocol = APIService.shared, 
         cacheService: CocktailCacheServiceProtocol = CocktailCacheService.shared) {
        self.apiService = apiService
        self.cacheService = cacheService
        loadPopularCocktails()
    }
    
    func performSearch() {
        guard !searchText.isEmpty else {
            searchResults = []
            hasSearched = false
            return
        }
        hasSearched = true
        searchCocktails(by: searchText)
    }
    
    func clearSearchResults() {
        searchResults = []
        hasSearched = false
        error = nil
        selectedLetter = nil
    }
    
    func searchCocktails(by name: String) {
        isLoading = true
        error = nil
        
        Task {
            do {
                let cocktails = try await apiService.fetchCocktailByName(name)
                
                let work = DispatchWorkItem {
                    self.searchResults = cocktails
                    self.isLoading = false
                }
                DispatchQueue.main.async(execute: work)
            } catch {
                let errorWork = DispatchWorkItem {
                    self.error = error
                    self.searchResults = []
                    self.isLoading = false
                }
                DispatchQueue.main.async(execute: errorWork)
            }
        }
    }
    
    func searchCocktailsByLetter(_ letter: String) {
        isLoading = true
        error = nil
        hasSearched = true
        selectedLetter = letter
        
        Task {
            do {
                let cocktails = try await apiService.fetchCocktailsByFirstLetter(letter)
                
                let work = DispatchWorkItem {
                    self.searchResults = cocktails
                    self.isLoading = false
                }
                DispatchQueue.main.async(execute: work)
            } catch {
                let errorWork = DispatchWorkItem {
                    self.error = error
                    self.searchResults = []
                    self.isLoading = false
                }
                DispatchQueue.main.async(execute: errorWork)
            }
        }
    }
    
    func loadPopularCocktails() {
        if let cachedCocktails = cacheService.getCachedPopularCocktails() {
            self.popularCocktails = cachedCocktails
            return
        }
        
        isLoading = true
        error = nil
        
        let cocktailIds = ["11000", "11001", "11002", "11003", "11004", "11005", "11006", "11007"]
        var loadedCocktails: [Cocktail] = []
        
        Task {
            do {
                for id in cocktailIds {
                    do {
                        let cocktail = try await apiService.fetchCocktailById(id)
                        loadedCocktails.append(cocktail)
                    } catch {
                        print("Ошибка при загрузке коктейля с ID \(id): \(error)")
                    }
                }
                
                let work = DispatchWorkItem {
                    self.isLoading = false
                    self.popularCocktails = loadedCocktails
                    
                    self.cacheService.cachePopularCocktails(loadedCocktails)
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
