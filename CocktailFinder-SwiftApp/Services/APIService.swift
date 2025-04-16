import Foundation

protocol CocktailServiceProtocol {
    func fetchCocktailByName(_ name: String) async throws -> [Cocktail]
    func fetchFilterOptions() async throws -> [FilterCategory]
    func fetchRandomCocktail() async throws -> Cocktail
    func fetchCocktailById(_ id: String) async throws -> Cocktail
    func fetchCocktailsByFilter(type: FilterType, value: String) async throws -> [Cocktail]
}

class APIService: CocktailServiceProtocol {
    static let shared = APIService()
    private let baseURL = "https://www.thecocktaildb.com/api/json/v1/1"
    private let decoder = JSONDecoder()
    private let session: URLSession
    
    private let maxConcurrentRequests = 5
    private let requestDelay: UInt64 = 200 * 1_000_000
    private let maxRetries = 1
    
    private var cocktailCache = NSCache<NSString, CacheEntry>()
    
    private init() {
        print("APIService initialized")
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 10
        configuration.waitsForConnectivity = false
        configuration.requestCachePolicy = .returnCacheDataElseLoad
        configuration.urlCache = URLCache(memoryCapacity: 10 * 1024 * 1024, diskCapacity: 50 * 1024 * 1024, diskPath: nil)
        
        session = URLSession(configuration: configuration)
        
        cocktailCache.countLimit = 100
    }
    
    func fetchCocktailByName(_ name: String) async throws -> [Cocktail] {
        let encodedName = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let url = URL(string: "\(baseURL)/search.php?s=\(encodedName)")!
        
        let (data, _) = try await URLSession.shared.data(from: url)
        return try decoder.decode(CocktailResponse.self, from: data).drinks
    }
    
    func fetchCocktailById(_ id: String) async throws -> Cocktail {
        try Task.checkCancellation()
        
        let cacheKey = NSString(string: "cocktail_\(id)")
        if let cachedData = cocktailCache.object(forKey: cacheKey), !cachedData.isExpired() {
            if let cocktail = cachedData.cocktails.first {
                return cocktail
            }
        }
        
        let url = URL(string: "\(baseURL)/lookup.php?i=\(id)")!
        
        do {
            let (data, response) = try await session.data(from: url)
            
            try Task.checkCancellation()
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw APIError.invalidResponse
            }
            
            let cocktailResponse = try decoder.decode(CocktailResponse.self, from: data)
            
            guard let cocktail = cocktailResponse.drinks.first else {
                throw APIError.decodingFailed
            }
            
            let cacheEntry = CacheEntry(cocktails: [cocktail])
            cocktailCache.setObject(cacheEntry, forKey: cacheKey)
            
            return cocktail
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            print("Ошибка при загрузке коктейля \(id): \(error)")
            throw error
        }
    }
    
    func fetchRandomCocktail() async throws -> Cocktail {
        let url = URL(string: "\(baseURL)/random.php")!
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        
        let cocktailResponse = try decoder.decode(CocktailResponse.self, from: data)
        
        guard let cocktail = cocktailResponse.drinks.first else {
            throw APIError.decodingFailed
        }
        
        return cocktail
    }
    
    func fetchCocktailsByFilter(type: FilterType, value: String) async throws -> [Cocktail] {
        try Task.checkCancellation()
        
        let cacheKey = NSString(string: "filter_\(type)_\(value)")
        if let cachedData = cocktailCache.object(forKey: cacheKey), !cachedData.isExpired() {
            print("Загружено из кеша: \(cacheKey)")
            return cachedData.cocktails
        }
        
        let encodedValue = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let endpoint: String
        
        switch type {
        case .category:
            endpoint = "filter.php?c=\(encodedValue)"
        case .glass:
            endpoint = "filter.php?g=\(encodedValue)"
        case .ingredient:
            endpoint = "filter.php?i=\(encodedValue)"
        case .alcoholic:
            endpoint = "filter.php?a=\(encodedValue)"
        }
        
        let url = URL(string: "\(baseURL)/\(endpoint)")!
        print("Fetching cocktails with filter: \(endpoint)")
        
        do {
            try Task.checkCancellation()
            
            let (data, response) = try await session.data(from: url)
            
            try Task.checkCancellation()
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw APIError.invalidResponse
            }
            
            try Task.checkCancellation()
            
            do {
                let filteredResponse = try decoder.decode(FilteredCocktailResponse.self, from: data)
                let totalCount = filteredResponse.drinks.count
                
                Task { @MainActor in
                    NotificationCenter.default.post(
                        name: Notification.Name("CocktailLoadingProgress"),
                        object: nil,
                        userInfo: ["progress": "Загрузка \(totalCount) коктейлей..."]
                    )
                }
                
                var fullCocktails: [Cocktail] = []
                fullCocktails.reserveCapacity(totalCount)
                
                for i in 0..<totalCount {
                    if i % maxConcurrentRequests == 0 {
                        try Task.checkCancellation()
                        
                        if i > 0 {
                            try await Task.sleep(nanoseconds: requestDelay)
                        }
                        
                        Task { @MainActor in
                            NotificationCenter.default.post(
                                name: Notification.Name("CocktailLoadingProgress"),
                                object: nil,
                                userInfo: ["progress": "Загружено \(i) из \(totalCount) коктейлей..."]
                            )
                        }
                    }
                    
                    let filteredCocktail = filteredResponse.drinks[i]
                    do {
                        let cocktail = try await fetchCocktailById(filteredCocktail.id)
                        fullCocktails.append(cocktail)
                    } catch is CancellationError {
                        throw CancellationError()
                    } catch {
                        print("Ошибка при загрузке коктейля \(filteredCocktail.id): \(error)")
                    }
                }
                
                try Task.checkCancellation()
                
                let cacheEntry = CacheEntry(cocktails: fullCocktails)
                cocktailCache.setObject(cacheEntry, forKey: cacheKey)
                
                Task { @MainActor in
                    NotificationCenter.default.post(
                        name: Notification.Name("CocktailLoadingComplete"),
                        object: nil,
                        userInfo: ["type": type, "value": value, "count": fullCocktails.count]
                    )
                }
                
                return fullCocktails
            } catch is CancellationError {
                throw CancellationError()
            } catch {
                print("Ошибка декодирования: \(error)")
                throw APIError.decodingFailed
            }
        } catch is CancellationError {
            print("Запрос был отменен")
            throw CancellationError()
        } catch {
            print("Ошибка сети: \(error)")
            throw error
        }
    }
    
    private func fetchCocktailByIdWithRetry(_ id: String, retries: Int) async throws -> Cocktail {
        var currentRetry = 0
        
        while true {
            do {
                if currentRetry > 0 {
                    let randomDelay = UInt64.random(in: 100...300) * 1_000_000
                    try await Task.sleep(nanoseconds: randomDelay)
                }
                
                return try await fetchCocktailById(id)
            } catch is CancellationError {
                throw CancellationError()
            } catch {
                if currentRetry >= retries {
                    throw error
                }
                
                currentRetry += 1
                print("Повторная попытка \(currentRetry)/\(retries) для коктейля \(id)")
            }
        }
    }
    
    func fetchFilterOptions() async throws -> [FilterCategory] {
        print("Fetching filter options")
        async let categories = fetchList(type: .category)
        async let glasses = fetchList(type: .glass)
        async let ingredients = fetchList(type: .ingredient)
        async let alcoholicOptions = fetchList(type: .alcoholic)
        
        let results = try await [
            FilterCategory(
                type: .category,
                name: "Категории",
                options: categories
            ),
            FilterCategory(
                type: .glass,
                name: "Стаканы",
                options: glasses
            ),
            FilterCategory(
                type: .ingredient,
                name: "Ингредиенты",
                options: ingredients
            ),
            FilterCategory(
                type: .alcoholic,
                name: "Тип напитка",
                options: alcoholicOptions
            )
        ]
        print("Received all filter options: \(results)")
        return results
    }

    private func fetchList(type: FilterType) async throws -> [FilterOption] {
        let endpoint: String
        switch type {
        case .category: endpoint = "list.php?c=list"
        case .glass: endpoint = "list.php?g=list"
        case .ingredient: endpoint = "list.php?i=list"
        case .alcoholic: endpoint = "list.php?a=list"
        }
        
        let url = URL(string: "\(baseURL)/\(endpoint)")!
        print("Fetching \(type) from URL: \(url)")
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            print("Invalid response for \(type)")
            throw APIError.invalidResponse
        }
        
        print("Received data for \(type): \(String(data: data, encoding: .utf8) ?? "none")")
        
        let listResponse = try decoder.decode(ListResponse.self, from: data)
        let results = listResponse.drinks.compactMap { entry -> String? in
            switch type {
            case .category: return entry.strCategory
            case .glass: return entry.strGlass
            case .ingredient: return entry.strIngredient
            case .alcoholic: return entry.strAlcoholic
            }
        }
        
        return results.map { FilterOption(name: $0, isSelected: false) }
    }
}

// MARK: - Вспомогательные структуры
fileprivate struct CocktailResponse: Decodable {
    let drinks: [Cocktail]
}

fileprivate struct FilteredCocktailResponse: Decodable {
    let drinks: [FilteredCocktail]
    
    struct FilteredCocktail: Decodable {
        let id: String
        let name: String
        let thumbnail: String
        
        enum CodingKeys: String, CodingKey {
            case id = "idDrink"
            case name = "strDrink"
            case thumbnail = "strDrinkThumb"
        }
    }
}

fileprivate struct ListResponse: Decodable {
    let drinks: [ListEntry]
    
    struct ListEntry: Decodable {
        let strCategory: String?
        let strGlass: String?
        let strIngredient: String?
        let strAlcoholic: String?
        
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let dict = try container.decode([String: String?].self)
            
            strCategory = dict["strCategory"] ?? nil
            strGlass = dict["strGlass"] ?? nil
            strIngredient = dict["strIngredient1"] ?? nil
            strAlcoholic = dict["strAlcoholic"] ?? nil
        }
    }
}

enum APIError: Error {
    case invalidURL
    case invalidResponse
    case decodingFailed
}

class CacheEntry {
    let cocktails: [Cocktail]
    private let timestamp: Date
    private let lifespan: TimeInterval = 60 * 30 
    
    init(cocktails: [Cocktail]) {
        self.cocktails = cocktails
        self.timestamp = Date()
    }
    
    func isExpired() -> Bool {
        return Date().timeIntervalSince(timestamp) > lifespan
    }
}
