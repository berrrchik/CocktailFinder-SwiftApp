import Foundation

protocol CocktailServiceProtocol {
    func fetchCocktailByName(_ name: String) async throws -> [Cocktail]
    func fetchFilterOptions() async throws -> [FilterCategory]
    func fetchRandomCocktail() async throws -> Cocktail
    func fetchCocktailById(_ id: String) async throws -> Cocktail
}

class APIService: CocktailServiceProtocol {
    static let shared = APIService()
    private let baseURL = "https://www.thecocktaildb.com/api/json/v1/1"
    private let decoder = JSONDecoder()
    
    private init() {
        print("APIService initialized")
    }
    
    func fetchCocktailByName(_ name: String) async throws -> [Cocktail] {
        let encodedName = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let url = URL(string: "\(baseURL)/search.php?s=\(encodedName)")!
        
        let (data, _) = try await URLSession.shared.data(from: url)
        return try decoder.decode(CocktailResponse.self, from: data).drinks
    }
    
    func fetchCocktailById(_ id: String) async throws -> Cocktail {
        let url = URL(string: "\(baseURL)/lookup.php?i=\(id)")!
        
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
