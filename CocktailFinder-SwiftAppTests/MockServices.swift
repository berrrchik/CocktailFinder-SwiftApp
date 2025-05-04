import Foundation
@testable import CocktailFinder_SwiftApp

class MockCocktailService: CocktailServiceProtocol {
    var shouldThrowError = false
    var delayInSeconds: Double? = nil
    
    var mockedCocktails: [Cocktail] = []
    var mockedFilterCategories: [FilterCategory] = []
    var mockedRandomCocktail: Cocktail?
    var mockedCocktailById: [String: Cocktail] = [:]
    var mockedFilteredCocktails: [FilterType: [String: [Cocktail]]] = [:]
    
    var fetchCocktailByNameCalled = false
    var fetchFilterOptionsCalled = false
    var fetchRandomCocktailCalled = false
    var fetchCocktailByIdCalled = false
    var fetchCocktailsByFilterCalled = false
    
    func fetchCocktailByName(_ name: String) async throws -> [Cocktail] {
        fetchCocktailByNameCalled = true
        
        if let delay = delayInSeconds {
            try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        }
        
        if shouldThrowError {
            throw APIError.invalidResponse
        }
        
        return mockedCocktails
    }
    
    func fetchFilterOptions() async throws -> [FilterCategory] {
        fetchFilterOptionsCalled = true
        
        if let delay = delayInSeconds {
            try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        }
        
        if shouldThrowError {
            throw APIError.invalidResponse
        }
        
        return mockedFilterCategories
    }
    
    func fetchRandomCocktail() async throws -> Cocktail {
        fetchRandomCocktailCalled = true
        
        if let delay = delayInSeconds {
            try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        }
        
        if shouldThrowError {
            throw APIError.invalidResponse
        }
        
        guard let cocktail = mockedRandomCocktail else {
            throw APIError.decodingFailed
        }
        
        return cocktail
    }
    
    func fetchCocktailById(_ id: String) async throws -> Cocktail {
        fetchCocktailByIdCalled = true
        
        if let delay = delayInSeconds {
            try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        }
        
        if shouldThrowError {
            throw APIError.invalidResponse
        }
        
        guard let cocktail = mockedCocktailById[id] else {
            throw APIError.decodingFailed
        }
        
        return cocktail
    }
    
    func fetchCocktailsByFilter(type: FilterType, value: String) async throws -> [Cocktail] {
        fetchCocktailsByFilterCalled = true
        
        if let delay = delayInSeconds {
            try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        }
        
        if shouldThrowError {
            throw APIError.invalidResponse
        }
        
        guard let typeDict = mockedFilteredCocktails[type],
              let cocktails = typeDict[value] else {
            return []
        }
        
        return cocktails
    }
    
    func reset() {
        shouldThrowError = false
        delayInSeconds = nil
        fetchCocktailByNameCalled = false
        fetchFilterOptionsCalled = false
        fetchRandomCocktailCalled = false
        fetchCocktailByIdCalled = false
        fetchCocktailsByFilterCalled = false
    }
    
    static func createSampleCocktail(id: String = "11000") -> Cocktail {
        let cocktail = try! JSONDecoder().decode(Cocktail.self, from: sampleCocktailJSON())
        return cocktail
    }
    
    static func sampleCocktailJSON() -> Data {
        let jsonString = """
        {
            "idDrink": "11000",
            "strDrink": "Mojito",
            "strTags": "IBA,ContemporaryClassic",
            "strCategory": "Cocktail",
            "strAlcoholic": "Alcoholic",
            "strGlass": "Highball glass",
            "strInstructions": "Muddle mint leaves with sugar and lime juice. Add a splash of soda water and fill with cracked ice. Pour rum and top with soda water. Garnish with mint leaves and lime wedge.",
            "strDrinkThumb": "https://www.thecocktaildb.com/images/media/drink/metwgh1606770327.jpg",
            "strIngredient1": "Light rum",
            "strIngredient2": "Lime",
            "strIngredient3": "Sugar",
            "strIngredient4": "Mint",
            "strIngredient5": "Soda water",
            "strMeasure1": "2-3 oz",
            "strMeasure2": "Juice of 1",
            "strMeasure3": "2 tsp",
            "strMeasure4": "2-4",
            "strMeasure5": "Fill"
        }
        """
        
        return jsonString.data(using: .utf8)!
    }
}

class MockFavoritesService: FavoritesServiceProtocol {
    var favorites: [Cocktail] = []
    
    var shouldThrowError = false
    
    init() {}
    
    func addToFavorites(_ cocktail: Cocktail) {
        var modifiedCocktail = cocktail
        modifiedCocktail.isFavorite = true
        
        if !isFavorite(cocktail) {
            favorites.append(modifiedCocktail)
        }
    }
    
    func removeFromFavorites(_ cocktail: Cocktail) {
        favorites.removeAll { $0.id == cocktail.id }
    }
    
    func isFavorite(_ cocktail: Cocktail) -> Bool {
        return favorites.contains { $0.id == cocktail.id }
    }
    
    func getFavorites() -> [Cocktail] {
        return favorites
    }
    
    func reset() {
        favorites = []
        shouldThrowError = false
    }
} 
