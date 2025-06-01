import XCTest
import Combine
@testable import CocktailFinder_SwiftApp

class SearchViewModelTests: XCTestCase {
    var viewModel: SearchViewModel!
    var mockAPIService: MockCocktailService!
    var cancellables = Set<AnyCancellable>()
    
    override func setUpWithError() throws {
        mockAPIService = MockCocktailService()
        
        class TestableSearchViewModel: SearchViewModel {
            let mockAPIService: MockCocktailService
            
            init(mockAPIService: MockCocktailService) {
                self.mockAPIService = mockAPIService
                super.init()
            }
            
            override func searchCocktails(by name: String) {
                isLoading = true
                error = nil
                
                Task {
                    do {
                        let cocktails = try await mockAPIService.fetchCocktailByName(name)
                        
                        await MainActor.run {
                            self.searchResults = cocktails
                            self.isLoading = false
                        }
                    } catch {
                        await MainActor.run {
                            self.error = error
                            self.searchResults = []
                            self.isLoading = false
                        }
                    }
                }
            }
            
            override func loadPopularCocktails() {
                isLoading = true
                
                Task {
                    do {
                        // Имитация задержки сети
                        try await Task.sleep(nanoseconds: 100_000_000)
                        
                        await MainActor.run {
                            self.popularCocktails = mockAPIService.mockedCocktails
                            self.isLoading = false
                        }
                    } catch {
                        await MainActor.run {
                            self.error = error
                            self.isLoading = false
                        }
                    }
                }
            }
        }
        
        viewModel = TestableSearchViewModel(mockAPIService: mockAPIService)
    }
    
    override func tearDownWithError() throws {
        viewModel = nil
        mockAPIService = nil
        cancellables.removeAll()
    }
    
    func testPerformSearchWithEmptyText() {
        viewModel.searchText = ""
        viewModel.searchResults = [MockCocktailService.createSampleCocktail(id: "11000")]
        viewModel.hasSearched = true
        
        viewModel.performSearch()
        
        XCTAssertFalse(viewModel.hasSearched)
        XCTAssertTrue(viewModel.searchResults.isEmpty)
    }
    
    func testClearSearchResults() {
        viewModel.searchResults = [MockCocktailService.createSampleCocktail(id: "11000")]
        viewModel.hasSearched = true
        viewModel.error = NSError(domain: "test", code: 123, userInfo: nil)
        
        viewModel.clearSearchResults()
        
        XCTAssertFalse(viewModel.hasSearched)
        XCTAssertTrue(viewModel.searchResults.isEmpty)
        XCTAssertNil(viewModel.error)
    }
    
    func testSearchCocktailsSuccess() async {
        let expectedCocktails = [
            MockCocktailService.createSampleCocktail(id: "11000"),
            MockCocktailService.createSampleCocktail(id: "11001")
        ]
        mockAPIService.mockedCocktails = expectedCocktails
        
        let expectation = expectation(description: "Search completes successfully")
        
        viewModel.$isLoading
            .dropFirst()
            .filter { !$0 }
            .first()
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.searchText = "Mojito"
        viewModel.performSearch()
        
        await fulfillment(of: [expectation], timeout: 5.0)
        
        XCTAssertTrue(mockAPIService.fetchCocktailByNameCalled)
        XCTAssertEqual(viewModel.searchResults.count, expectedCocktails.count)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.error)
    }
    
    func testSearchCocktailsError() async {
        mockAPIService.shouldThrowError = true
        
        let expectation = expectation(description: "Search completes with error")
        
        viewModel.$isLoading
            .dropFirst()
            .filter { !$0 }
            .first()
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.searchText = "Mojito"
        viewModel.performSearch()
        
        await fulfillment(of: [expectation], timeout: 5.0)
        
        XCTAssertTrue(mockAPIService.fetchCocktailByNameCalled)
        XCTAssertTrue(viewModel.searchResults.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNotNil(viewModel.error)
    }
    
    func testLoadPopularCocktailsSuccess() async {
        let expectedCocktails = [
            MockCocktailService.createSampleCocktail(id: "11000"),
            MockCocktailService.createSampleCocktail(id: "11001")
        ]
        mockAPIService.mockedCocktails = expectedCocktails
        
        let expectation = expectation(description: "Popular cocktails load successfully")
        
        viewModel.$isLoading
            .dropFirst()
            .filter { !$0 }
            .first()
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.loadPopularCocktails()
        
        await fulfillment(of: [expectation], timeout: 5.0)
        
        XCTAssertEqual(viewModel.popularCocktails.count, expectedCocktails.count)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.error)
    }
} 
