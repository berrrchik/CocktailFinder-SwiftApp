import Foundation
import Combine

class SearchViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var popularCocktails: [Cocktail] = []
    @Published var searchResults: [Cocktail] = []
    @Published var isLoading: Bool = false
    @Published var error: Error? = nil
    
    private let apiService = APIService.shared
    private var cancellables = Set<AnyCancellable>()
    
    private let cacheKey = "popularCocktailsCache"
    private let cacheExpirationKey = "popularCocktailsCacheExpiration"
    private let cacheExpirationTime: TimeInterval = 24 * 60 * 60
    
    init() {
        $searchText
            .debounce(for: .seconds(0.1), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] searchTerm in
                if !searchTerm.isEmpty {
                    self?.searchCocktails(by: searchTerm)
                } else {
                    self?.searchResults = []
                }
            }
            .store(in: &cancellables)
        
        loadPopularCocktails()
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
    
    func loadPopularCocktails() {
        if let cachedCocktails = getCachedPopularCocktails() {
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
                    
                    self.cachePopularCocktails(loadedCocktails)
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
    
    private func cachePopularCocktails(_ cocktails: [Cocktail]) {
        do {
            let data = try JSONEncoder().encode(cocktails)
            UserDefaults.standard.set(data, forKey: cacheKey)
            
            let expirationDate = Date().addingTimeInterval(cacheExpirationTime)
            UserDefaults.standard.set(expirationDate.timeIntervalSince1970, forKey: cacheExpirationKey)
        } catch {
            print("Ошибка при кэшировании коктейлей: \(error)")
        }
    }
    
    private func getCachedPopularCocktails() -> [Cocktail]? {
        if let expirationTimeInterval = UserDefaults.standard.object(forKey: cacheExpirationKey) as? TimeInterval {
            let expirationDate = Date(timeIntervalSince1970: expirationTimeInterval)
            
            if Date() > expirationDate {
                UserDefaults.standard.removeObject(forKey: cacheKey)
                UserDefaults.standard.removeObject(forKey: cacheExpirationKey)
                return nil
            }
            
            if let cachedData = UserDefaults.standard.data(forKey: cacheKey) {
                do {
                    let cocktails = try JSONDecoder().decode([Cocktail].self, from: cachedData)
                    return cocktails
                } catch {
                    print("Ошибка при декодировании кэша: \(error)")
                }
            }
        }
        
        return nil
    }
} 
