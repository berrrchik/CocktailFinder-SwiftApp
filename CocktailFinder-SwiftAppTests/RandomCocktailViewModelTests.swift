import XCTest
import Combine
@testable import CocktailFinder_SwiftApp

class RandomCocktailViewModelTests: XCTestCase {
    var viewModel: RandomCocktailViewModel!
    var mockAPIService: MockCocktailService!
    var cancellables = Set<AnyCancellable>()
    
    override func setUpWithError() throws {
        mockAPIService = MockCocktailService()
        mockAPIService.delayInSeconds = 0.1
    }
    
    override func tearDownWithError() throws {
        viewModel = nil
        mockAPIService = nil
        cancellables.removeAll()
    }
    
    func testInitAndLoadRandomCocktail() async {
        let testCocktail = MockCocktailService.createSampleCocktail()
        mockAPIService.mockedRandomCocktail = testCocktail
        
        let expectation = expectation(description: "Random cocktail loads successfully")
        
        viewModel = RandomCocktailViewModel(apiService: mockAPIService)
        
        viewModel.$cocktail
            .compactMap { $0 }
            .first()
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        await fulfillment(of: [expectation], timeout: 5.0)
        
        XCTAssertTrue(mockAPIService.fetchRandomCocktailCalled)
        XCTAssertNotNil(viewModel.cocktail)
        XCTAssertEqual(viewModel.cocktail?.id, testCocktail.id)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.error)
    }
    
    func testLoadRandomCocktailError() async {
        mockAPIService.shouldThrowError = true
        
        let expectation = expectation(description: "Error occurs during loading")
        
        viewModel = RandomCocktailViewModel(apiService: mockAPIService)
        
        viewModel.$error
            .compactMap { $0 }
            .first()
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        await fulfillment(of: [expectation], timeout: 5.0)
        
        XCTAssertTrue(mockAPIService.fetchRandomCocktailCalled)
        XCTAssertNil(viewModel.cocktail)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNotNil(viewModel.error)
    }
    
    func testLoadRandomCocktailManually() async {
        let testCocktail1 = MockCocktailService.createSampleCocktail(id: "11000")
        let testCocktail2 = MockCocktailService.createSampleCocktail(id: "11001")
        mockAPIService.mockedRandomCocktail = testCocktail1
        
        viewModel = RandomCocktailViewModel(apiService: mockAPIService)
        
        let firstLoadExpectation = expectation(description: "First random cocktail loads")
        
        viewModel.$isLoading
            .dropFirst()
            .filter { !$0 }
            .first()
            .sink { _ in
                firstLoadExpectation.fulfill()
            }
            .store(in: &cancellables)
        
        await fulfillment(of: [firstLoadExpectation], timeout: 5.0)
        
        XCTAssertNotNil(viewModel.cocktail)
        XCTAssertEqual(viewModel.cocktail?.id, testCocktail1.id)
        
        mockAPIService.fetchRandomCocktailCalled = false
        mockAPIService.mockedRandomCocktail = testCocktail2
        
        let secondLoadExpectation = expectation(description: "Second random cocktail loads")
        
        viewModel.$cocktail
            .dropFirst()
            .sink { cocktail in
                if cocktail?.id == testCocktail2.id {
                    secondLoadExpectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.loadRandomCocktail()
        
        await fulfillment(of: [secondLoadExpectation], timeout: 5.0)
        
        XCTAssertTrue(mockAPIService.fetchRandomCocktailCalled)
        XCTAssertEqual(viewModel.cocktail?.id, testCocktail2.id)
    }
    
    func testLoadingState() {
        mockAPIService.delayInSeconds = 1.0
        viewModel = RandomCocktailViewModel(apiService: mockAPIService)
        
        XCTAssertTrue(viewModel.isLoading)
        XCTAssertNil(viewModel.cocktail)
        XCTAssertNil(viewModel.error)
    }
} 
