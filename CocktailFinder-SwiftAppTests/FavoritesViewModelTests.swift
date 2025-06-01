import XCTest
import Combine
@testable import CocktailFinder_SwiftApp

class FavoritesViewModelTests: XCTestCase {
    var viewModel: FavoritesViewModel!
    var mockFavoritesService: MockFavoritesService!
    var cancellables = Set<AnyCancellable>()
    
    override func setUpWithError() throws {
        mockFavoritesService = MockFavoritesService()
        viewModel = FavoritesViewModel(favoritesService: mockFavoritesService)
    }
    
    override func tearDownWithError() throws {
        viewModel = nil
        mockFavoritesService = nil
        cancellables.removeAll()
    }
    
    func testInitWithEmptyFavorites() {
        XCTAssertTrue(viewModel.favorites.isEmpty)
        XCTAssertTrue(viewModel.isFavoriteEmpty())
    }
    
    func testInitWithExistingFavorites() {
        let testCocktail1 = MockCocktailService.createSampleCocktail(id: "11000")
        let testCocktail2 = MockCocktailService.createSampleCocktail(id: "11001")
        
        mockFavoritesService.addToFavorites(testCocktail1)
        mockFavoritesService.addToFavorites(testCocktail2)
        
        viewModel = FavoritesViewModel(favoritesService: mockFavoritesService)
        
        XCTAssertEqual(viewModel.favorites.count, 2)
        XCTAssertFalse(viewModel.isFavoriteEmpty())
    }
    
    func testLoadFavorites() {
        let testCocktail = MockCocktailService.createSampleCocktail(id: "11000")
        
        mockFavoritesService.addToFavorites(testCocktail)
        
        XCTAssertTrue(viewModel.favorites.isEmpty)
        
        viewModel.loadFavorites()
        
        XCTAssertEqual(viewModel.favorites.count, 1)
        XCTAssertEqual(viewModel.favorites[0].id, testCocktail.id)
        XCTAssertFalse(viewModel.isFavoriteEmpty())
    }
    
    func testRemoveFavorite() {
        let testCocktail1 = MockCocktailService.createSampleCocktail(id: "11000")
        let testCocktail2 = MockCocktailService.createSampleCocktail(id: "11001")
        
        mockFavoritesService.addToFavorites(testCocktail1)
        mockFavoritesService.addToFavorites(testCocktail2)
        
        viewModel = FavoritesViewModel(favoritesService: mockFavoritesService)
        
        XCTAssertEqual(viewModel.favorites.count, 2)
        
        viewModel.removeFavorite(testCocktail1)
        
        XCTAssertEqual(viewModel.favorites.count, 1)
        XCTAssertEqual(viewModel.favorites[0].id, testCocktail2.id)
        XCTAssertFalse(viewModel.isFavoriteEmpty())
    }
    
    func testRemoveLastFavorite() {
        let testCocktail = MockCocktailService.createSampleCocktail(id: "11000")
        
        mockFavoritesService.addToFavorites(testCocktail)
        viewModel = FavoritesViewModel(favoritesService: mockFavoritesService)
        
        XCTAssertEqual(viewModel.favorites.count, 1)
        XCTAssertFalse(viewModel.isFavoriteEmpty())
        
        viewModel.removeFavorite(testCocktail)
        
        XCTAssertTrue(viewModel.favorites.isEmpty)
        XCTAssertTrue(viewModel.isFavoriteEmpty())
    }
    
    func testIsFavoriteEmpty() {
        XCTAssertTrue(viewModel.isFavoriteEmpty())
        
        let testCocktail = MockCocktailService.createSampleCocktail(id: "11000")
        mockFavoritesService.addToFavorites(testCocktail)
        viewModel.loadFavorites()
        
        XCTAssertFalse(viewModel.isFavoriteEmpty())
        
        viewModel.removeFavorite(testCocktail)
        
        XCTAssertTrue(viewModel.isFavoriteEmpty())
    }
    
    func testMultipleOperations() {
        let cocktail1 = MockCocktailService.createSampleCocktail(id: "11000")
        let cocktail2 = MockCocktailService.createSampleCocktail(id: "11001")
        let cocktail3 = MockCocktailService.createSampleCocktail(id: "11002")
        
        mockFavoritesService.addToFavorites(cocktail1)
        mockFavoritesService.addToFavorites(cocktail2)
        mockFavoritesService.addToFavorites(cocktail3)
        
        viewModel.loadFavorites()
        XCTAssertEqual(viewModel.favorites.count, 3)
        
        viewModel.removeFavorite(cocktail2)
        XCTAssertEqual(viewModel.favorites.count, 2)
        
        let remainingIds = viewModel.favorites.map { $0.id }
        XCTAssertTrue(remainingIds.contains(cocktail1.id))
        XCTAssertFalse(remainingIds.contains(cocktail2.id))
        XCTAssertTrue(remainingIds.contains(cocktail3.id))
    }
} 