import Foundation
@testable import CocktailFinder_SwiftApp

class MockCocktailService: APIServiceProtocol {
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
    
    func fetchCocktailsByFirstLetter(_ letter: String) async throws -> [Cocktail] {
        if shouldThrowError {
            throw APIError.invalidResponse
        }
        
        return mockedCocktails
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
        let jsonData: Data
        switch id {
        case "11001":
            jsonData = margaritaJSON()
        case "11002":
            jsonData = pinaColadaJSON()
        case "11003":
            jsonData = cosmopolitanJSON()
        default:
            jsonData = mojitoJSON()
        }
        
        do {
            return try JSONDecoder().decode(Cocktail.self, from: jsonData)
        } catch {
            fatalError("Ошибка декодирования тестового коктейля: \(error)")
        }
    }
    
    static func mojitoJSON() -> Data {
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
        guard let data = jsonString.data(using: .utf8) else {
            fatalError("Не удалось преобразовать строку JSON в данные")
        }
        return data
    }
    
    static func margaritaJSON() -> Data {
        let jsonString = """
        {
            "idDrink": "11001",
            "strDrink": "Margarita",
            "strTags": "IBA,ContemporaryClassic",
            "strCategory": "Ordinary Drink",
            "strAlcoholic": "Alcoholic",
            "strGlass": "Cocktail glass",
            "strInstructions": "Rub the rim of the glass with the lime slice to make the salt stick to it. Take care to moisten only the outer rim and sprinkle the salt on it. The salt should present to the lips of the imbiber and never mix into the cocktail. Shake the other ingredients with ice, then carefully pour into the glass.",
            "strDrinkThumb": "https://www.thecocktaildb.com/images/media/drink/5noda61589575158.jpg",
            "strIngredient1": "Tequila",
            "strIngredient2": "Triple sec",
            "strIngredient3": "Lime juice",
            "strIngredient4": "Salt",
            "strMeasure1": "1 1/2 oz",
            "strMeasure2": "1/2 oz",
            "strMeasure3": "1 oz",
            "strMeasure4": "Pinch"
        }
        """
        guard let data = jsonString.data(using: .utf8) else {
            fatalError("Не удалось преобразовать строку JSON в данные")
        }
        return data
    }
    
    static func pinaColadaJSON() -> Data {
        let jsonString = """
        {
            "idDrink": "11002",
            "strDrink": "Pina Colada",
            "strTags": "IBA,ContemporaryClassic,Coconut",
            "strCategory": "Ordinary Drink",
            "strAlcoholic": "Alcoholic",
            "strGlass": "Hurricane glass",
            "strInstructions": "Mix with crushed ice in blender until smooth. Pour into chilled glass, garnish and serve.",
            "strDrinkThumb": "https://www.thecocktaildb.com/images/media/drink/cpf4jb1606768744.jpg",
            "strIngredient1": "White rum",
            "strIngredient2": "Coconut milk",
            "strIngredient3": "Pineapple",
            "strMeasure1": "3 oz",
            "strMeasure2": "3 tbsp",
            "strMeasure3": "3 oz"
        }
        """
        guard let data = jsonString.data(using: .utf8) else {
            fatalError("Не удалось преобразовать строку JSON в данные")
        }
        return data
    }
    
    static func cosmopolitanJSON() -> Data {
        let jsonString = """
        {
            "idDrink": "11003",
            "strDrink": "Cosmopolitan",
            "strTags": "IBA,ContemporaryClassic",
            "strCategory": "Cocktail",
            "strAlcoholic": "Alcoholic",
            "strGlass": "Cocktail glass",
            "strInstructions": "Add all ingredients to cocktail shaker filled with ice. Shake well and double strain into chilled cocktail glass. Garnish with lime wheel.",
            "strDrinkThumb": "https://www.thecocktaildb.com/images/media/drink/kpsajh1504368362.jpg",
            "strIngredient1": "Vodka",
            "strIngredient2": "Lime juice",
            "strIngredient3": "Cointreau",
            "strIngredient4": "Cranberry juice",
            "strMeasure1": "1 1/4 oz",
            "strMeasure2": "1/4 oz",
            "strMeasure3": "1/4 oz",
            "strMeasure4": "1/4 cup"
        }
        """
        guard let data = jsonString.data(using: .utf8) else {
            fatalError("Не удалось преобразовать строку JSON в данные")
        }
        return data
    }
    
    static func sampleCocktailJSON() -> Data {
        return mojitoJSON()
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
