import XCTest
import Combine
@testable import CocktailFinder_SwiftApp

class CocktailCardViewModelTests: XCTestCase {
    var viewModel: CocktailCardViewModel!
    var mockFavoritesService: MockFavoritesService!
    var cancellables = Set<AnyCancellable>()
    
    override func setUpWithError() throws {
        mockFavoritesService = MockFavoritesService()
        let sampleCocktail = MockCocktailService.createSampleCocktail()
        
        viewModel = CocktailCardViewModel(
            cocktail: sampleCocktail, 
            favoritesService: mockFavoritesService
        )
    }
    
    override func tearDownWithError() throws {
        viewModel = nil
        mockFavoritesService = nil
        cancellables.removeAll()
    }
    
    func testCheckIsFavorite() throws {
        XCTAssertFalse(viewModel.isFavorite)
        
        mockFavoritesService.addToFavorites(viewModel.cocktail)
        
        viewModel.checkIsFavorite()
        XCTAssertTrue(viewModel.isFavorite)
    }
    
    func testToggleFavoriteAdd() throws {
        let expectation = expectation(description: "isFavorite изменится на true")
        
        viewModel.$isFavorite
            .dropFirst()
            .first()
            .sink { value in
                XCTAssertTrue(value)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.toggleFavorite()
        
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertEqual(mockFavoritesService.favorites.count, 1)
        XCTAssertEqual(mockFavoritesService.favorites[0].id, viewModel.cocktail.id)
    }
    
    func testToggleFavoriteRemove() throws {
        mockFavoritesService.addToFavorites(viewModel.cocktail)
        viewModel.checkIsFavorite()
        XCTAssertTrue(viewModel.isFavorite)
        
        let expectation = expectation(description: "isFavorite изменится на false")
        
        viewModel.$isFavorite
            .dropFirst()
            .first()
            .sink { value in
                XCTAssertFalse(value)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.toggleFavorite()
        
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertEqual(mockFavoritesService.favorites.count, 0)
    }
} 
