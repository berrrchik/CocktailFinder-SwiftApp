import Foundation

protocol CocktailCacheServiceProtocol {
    func cachePopularCocktails(_ cocktails: [Cocktail])
    func getCachedPopularCocktails() -> [Cocktail]?
    func isCacheValid() -> Bool
    func clearCache()
}

class CocktailCacheService: CocktailCacheServiceProtocol {
    static let shared = CocktailCacheService()
    
    private init() {}
    
    // Ключи для хранения данных в UserDefaults
    private let cacheKey = "popularCocktailsCache"
    private let cacheExpirationKey = "popularCocktailsCacheExpiration"
    private let cacheExpirationTime: TimeInterval = 24 * 60 * 60 // 24 часа
    
    func cachePopularCocktails(_ cocktails: [Cocktail]) {
        do {
            let data = try JSONEncoder().encode(cocktails)
            UserDefaults.standard.set(data, forKey: cacheKey)
            
            let expirationDate = Date().addingTimeInterval(cacheExpirationTime)
            UserDefaults.standard.set(expirationDate.timeIntervalSince1970, forKey: cacheExpirationKey)
        } catch {
            print("Ошибка при кэшировании коктейлей: \(error)")
        }
    }
    
    func getCachedPopularCocktails() -> [Cocktail]? {
        if let expirationTimeInterval = UserDefaults.standard.object(forKey: cacheExpirationKey) as? TimeInterval {
            let expirationDate = Date(timeIntervalSince1970: expirationTimeInterval)
            
            if Date() > expirationDate {
                clearCache()
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
    
    func isCacheValid() -> Bool {
        if let expirationTimeInterval = UserDefaults.standard.object(forKey: cacheExpirationKey) as? TimeInterval {
            let expirationDate = Date(timeIntervalSince1970: expirationTimeInterval)
            return Date() <= expirationDate && UserDefaults.standard.data(forKey: cacheKey) != nil
        }
        return false
    }
    
    func clearCache() {
        UserDefaults.standard.removeObject(forKey: cacheKey)
        UserDefaults.standard.removeObject(forKey: cacheExpirationKey)
    }
} 