import XCTest
@testable import CocktailFinder_SwiftApp

class FavoritesServiceTests: XCTestCase {
    var favoritesService: FavoritesService!
    private let testKey = "test_favoriteCocktails"
    
    override func setUpWithError() throws {
        UserDefaults.standard.removeObject(forKey: "favoriteCocktails")
        UserDefaults.standard.removeObject(forKey: testKey)
        
        favoritesService = FavoritesService.shared
    }
    
    override func tearDownWithError() throws {
        UserDefaults.standard.removeObject(forKey: "favoriteCocktails")
        UserDefaults.standard.removeObject(forKey: testKey)
        favoritesService = nil
    }
    
    func testInitialStateEmpty() {
        let favorites = favoritesService.getFavorites()
        XCTAssertTrue(favorites.isEmpty)
    }
    
    func testAddToFavorites() {
        let cocktail = MockCocktailService.createSampleCocktail(id: "11000")
        
        XCTAssertFalse(favoritesService.isFavorite(cocktail))
        
        favoritesService.addToFavorites(cocktail)
        
        XCTAssertTrue(favoritesService.isFavorite(cocktail))
        
        let favorites = favoritesService.getFavorites()
        XCTAssertEqual(favorites.count, 1)
        XCTAssertEqual(favorites[0].id, cocktail.id)
    }
    
    func testAddDuplicateFavorite() {
        let cocktail = MockCocktailService.createSampleCocktail(id: "11000")
        
        favoritesService.addToFavorites(cocktail)
        favoritesService.addToFavorites(cocktail)
        
        let favorites = favoritesService.getFavorites()
        XCTAssertEqual(favorites.count, 1)
    }
    
    func testRemoveFromFavorites() {
        let cocktail = MockCocktailService.createSampleCocktail(id: "11000")
        
        favoritesService.addToFavorites(cocktail)
        XCTAssertTrue(favoritesService.isFavorite(cocktail))
        
        favoritesService.removeFromFavorites(cocktail)
        XCTAssertFalse(favoritesService.isFavorite(cocktail))
        
        let favorites = favoritesService.getFavorites()
        XCTAssertTrue(favorites.isEmpty)
    }
    
    func testRemoveNonExistentFavorite() {
        let cocktail1 = MockCocktailService.createSampleCocktail(id: "11000")
        let cocktail2 = MockCocktailService.createSampleCocktail(id: "11001")
        
        favoritesService.addToFavorites(cocktail1)
        
        favoritesService.removeFromFavorites(cocktail2)
        
        let favorites = favoritesService.getFavorites()
        XCTAssertEqual(favorites.count, 1)
        XCTAssertEqual(favorites[0].id, cocktail1.id)
    }
    
    func testIsFavorite() {
        let cocktail1 = MockCocktailService.createSampleCocktail(id: "11000")
        let cocktail2 = MockCocktailService.createSampleCocktail(id: "11001")
        
        XCTAssertFalse(favoritesService.isFavorite(cocktail1))
        XCTAssertFalse(favoritesService.isFavorite(cocktail2))
        
        favoritesService.addToFavorites(cocktail1)
        
        XCTAssertTrue(favoritesService.isFavorite(cocktail1))
        XCTAssertFalse(favoritesService.isFavorite(cocktail2))
    }
    
    func testMultipleFavorites() {
        let cocktails = [
            MockCocktailService.createSampleCocktail(id: "11000"),
            MockCocktailService.createSampleCocktail(id: "11001"),
            MockCocktailService.createSampleCocktail(id: "11002")
        ]
        
        // Добавляем все коктейли
        for cocktail in cocktails {
            favoritesService.addToFavorites(cocktail)
        }
        
        let favorites = favoritesService.getFavorites()
        XCTAssertEqual(favorites.count, 3)
        
        // Проверяем, что все добавлены
        for cocktail in cocktails {
            XCTAssertTrue(favoritesService.isFavorite(cocktail))
        }
        
        // Удаляем средний
        favoritesService.removeFromFavorites(cocktails[1])
        
        let updatedFavorites = favoritesService.getFavorites()
        XCTAssertEqual(updatedFavorites.count, 2)
        XCTAssertTrue(favoritesService.isFavorite(cocktails[0]))
        XCTAssertFalse(favoritesService.isFavorite(cocktails[1]))
        XCTAssertTrue(favoritesService.isFavorite(cocktails[2]))
    }
    
    func testPersistence() {
        let cocktail = MockCocktailService.createSampleCocktail(id: "11000")
        
        favoritesService.addToFavorites(cocktail)
        
        // Создаем новый экземпляр сервиса (имитация перезапуска приложения)
        let newService = FavoritesService.shared
        
        XCTAssertTrue(newService.isFavorite(cocktail))
        let favorites = newService.getFavorites()
        XCTAssertEqual(favorites.count, 1)
        XCTAssertEqual(favorites[0].id, cocktail.id)
    }
    
    func testGetFavoritesWithCorruptedData() {
        // Записываем невалидные данные в UserDefaults
        UserDefaults.standard.set("invalid data".data(using: .utf8), forKey: "favoriteCocktails")
        
        let favorites = favoritesService.getFavorites()
        
        // Должен вернуть пустой массив при ошибке декодирования
        XCTAssertTrue(favorites.isEmpty)
    }
} 
