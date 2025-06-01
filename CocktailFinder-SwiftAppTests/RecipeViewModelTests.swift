import XCTest
import Combine
@testable import CocktailFinder_SwiftApp

class RecipeViewModelTests: XCTestCase {
    var viewModel: RecipeViewModel!
    var mockAPIService: MockCocktailService!
    var mockFavoritesService: MockFavoritesService!
    var cancellables = Set<AnyCancellable>()
    
    override func setUpWithError() throws {
        mockAPIService = MockCocktailService()
        mockAPIService.delayInSeconds = 0.1
        mockFavoritesService = MockFavoritesService()
    }
    
    override func tearDownWithError() throws {
        viewModel = nil
        mockAPIService = nil
        mockFavoritesService = nil
        cancellables.removeAll()
    }
    
    func testInitWithDrinkId() async {
        let testCocktail = MockCocktailService.createSampleCocktail()
        mockAPIService.mockedCocktailById["11000"] = testCocktail
        
        let expectation = expectation(description: "Cocktail loads successfully")
        
        viewModel = RecipeViewModel(
            drinkId: "11000",
            apiService: mockAPIService,
            favoritesService: mockFavoritesService
        )
        
        viewModel.$cocktail
            .compactMap { $0 }
            .first()
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        await fulfillment(of: [expectation], timeout: 5.0)
        
        XCTAssertNotNil(viewModel.cocktail)
        XCTAssertEqual(viewModel.cocktail?.id, "11000")
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.error)
    }
    
    func testInitWithCocktail() {
        let testCocktail = MockCocktailService.createSampleCocktail()
        
        viewModel = RecipeViewModel(
            cocktail: testCocktail,
            favoritesService: mockFavoritesService
        )
        
        XCTAssertNotNil(viewModel.cocktail)
        XCTAssertEqual(viewModel.cocktail?.id, testCocktail.id)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.error)
    }
    
    func testLoadCocktailDataError() async {
        mockAPIService.shouldThrowError = true
        
        let expectation = expectation(description: "Error occurs during loading")
        
        viewModel = RecipeViewModel(
            drinkId: "invalid",
            apiService: mockAPIService,
            favoritesService: mockFavoritesService
        )
        
        viewModel.$error
            .compactMap { $0 }
            .first()
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        await fulfillment(of: [expectation], timeout: 5.0)
        
        XCTAssertNil(viewModel.cocktail)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNotNil(viewModel.error)
    }
    
    func testToggleFavoriteAdd() {
        let testCocktail = MockCocktailService.createSampleCocktail()
        
        viewModel = RecipeViewModel(
            cocktail: testCocktail,
            favoritesService: mockFavoritesService
        )
        
        XCTAssertFalse(viewModel.isFavorite)
        
        viewModel.toggleFavorite()
        
        XCTAssertTrue(viewModel.isFavorite)
        XCTAssertEqual(mockFavoritesService.favorites.count, 1)
        XCTAssertEqual(mockFavoritesService.favorites[0].id, testCocktail.id)
    }
    
    func testToggleFavoriteRemove() {
        let testCocktail = MockCocktailService.createSampleCocktail()
        mockFavoritesService.addToFavorites(testCocktail)
        
        viewModel = RecipeViewModel(
            cocktail: testCocktail,
            favoritesService: mockFavoritesService
        )
        
        XCTAssertTrue(viewModel.isFavorite)
        
        viewModel.toggleFavorite()
        
        XCTAssertFalse(viewModel.isFavorite)
        XCTAssertEqual(mockFavoritesService.favorites.count, 0)
    }
    
    func testLoadCocktailDataWithExistingCocktail() {
        let testCocktail = MockCocktailService.createSampleCocktail()
        
        viewModel = RecipeViewModel(
            cocktail: testCocktail,
            favoritesService: mockFavoritesService
        )
        
        viewModel.loadCocktailData()
        
        XCTAssertNotNil(viewModel.cocktail)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.error)
    }
} 
