import XCTest
@testable import CocktailFinder_SwiftApp

class CocktailCacheServiceTests: XCTestCase {
    var cacheService: CocktailCacheService!
    private let cacheKey = "popularCocktailsCache"
    private let cacheExpirationKey = "popularCocktailsCacheExpiration"
    
    override func setUpWithError() throws {
        UserDefaults.standard.removeObject(forKey: cacheKey)
        UserDefaults.standard.removeObject(forKey: cacheExpirationKey)
        
        cacheService = CocktailCacheService.shared
    }
    
    override func tearDownWithError() throws {
        UserDefaults.standard.removeObject(forKey: cacheKey)
        UserDefaults.standard.removeObject(forKey: cacheExpirationKey)
        cacheService = nil
    }
    
    func testInitialStateEmpty() {
        XCTAssertNil(cacheService.getCachedPopularCocktails())
        XCTAssertFalse(cacheService.isCacheValid())
    }
    
    func testCachePopularCocktails() {
        let cocktails = [
            MockCocktailService.createSampleCocktail(id: "11000"),
            MockCocktailService.createSampleCocktail(id: "11001")
        ]
        
        cacheService.cachePopularCocktails(cocktails)
        
        XCTAssertTrue(cacheService.isCacheValid())
        
        let cachedCocktails = cacheService.getCachedPopularCocktails()
        XCTAssertNotNil(cachedCocktails)
        XCTAssertEqual(cachedCocktails?.count, 2)
    }
    
    func testGetCachedPopularCocktails() {
        let originalCocktails = [
            MockCocktailService.createSampleCocktail(id: "11000"),
            MockCocktailService.createSampleCocktail(id: "11001")
        ]
        
        cacheService.cachePopularCocktails(originalCocktails)
        
        let cachedCocktails = cacheService.getCachedPopularCocktails()
        
        XCTAssertNotNil(cachedCocktails)
        XCTAssertEqual(cachedCocktails?.count, originalCocktails.count)
        
        for (index, cocktail) in originalCocktails.enumerated() {
            XCTAssertEqual(cachedCocktails?[index].id, cocktail.id)
            XCTAssertEqual(cachedCocktails?[index].name, cocktail.name)
        }
    }
    
    func testCacheExpiration() {
        let cocktails = [MockCocktailService.createSampleCocktail(id: "11000")]
        
        cacheService.cachePopularCocktails(cocktails)
        XCTAssertTrue(cacheService.isCacheValid())
        
        let pastDate = Date().addingTimeInterval(-25 * 60 * 60)
        UserDefaults.standard.set(pastDate.timeIntervalSince1970, forKey: cacheExpirationKey)
        
        XCTAssertFalse(cacheService.isCacheValid())
        XCTAssertNil(cacheService.getCachedPopularCocktails())
    }
    
    func testClearCache() {
        let cocktails = [MockCocktailService.createSampleCocktail(id: "11000")]
        
        cacheService.cachePopularCocktails(cocktails)
        XCTAssertTrue(cacheService.isCacheValid())
        XCTAssertNotNil(cacheService.getCachedPopularCocktails())
        
        cacheService.clearCache()
        
        XCTAssertFalse(cacheService.isCacheValid())
        XCTAssertNil(cacheService.getCachedPopularCocktails())
    }
    
    func testIsCacheValid() {
        XCTAssertFalse(cacheService.isCacheValid())
        
        let cocktails = [MockCocktailService.createSampleCocktail(id: "11000")]
        cacheService.cachePopularCocktails(cocktails)
        XCTAssertTrue(cacheService.isCacheValid())
        
        cacheService.clearCache()
        XCTAssertFalse(cacheService.isCacheValid())
    }
    
    func testCacheValidityWithTime() {
        let cocktails = [MockCocktailService.createSampleCocktail(id: "11000")]
        
        cacheService.cachePopularCocktails(cocktails)
        
        XCTAssertTrue(cacheService.isCacheValid())
        
        let futureDate = Date().addingTimeInterval(23 * 60 * 60)
        UserDefaults.standard.set(futureDate.timeIntervalSince1970, forKey: cacheExpirationKey)
        
        XCTAssertTrue(cacheService.isCacheValid())
        
        let pastDate = Date().addingTimeInterval(-1 * 60 * 60)
        UserDefaults.standard.set(pastDate.timeIntervalSince1970, forKey: cacheExpirationKey)
        
        XCTAssertFalse(cacheService.isCacheValid())
    }
    
    func testEmptyArrayCaching() {
        let emptyCocktails: [Cocktail] = []
        
        cacheService.cachePopularCocktails(emptyCocktails)
        
        XCTAssertTrue(cacheService.isCacheValid())
        
        let cachedCocktails = cacheService.getCachedPopularCocktails()
        XCTAssertNotNil(cachedCocktails)
        XCTAssertTrue(cachedCocktails?.isEmpty ?? false)
    }
    
    func testCacheOverwrite() {
        let firstCocktails = [MockCocktailService.createSampleCocktail(id: "11000")]
        let secondCocktails = [
            MockCocktailService.createSampleCocktail(id: "11001"),
            MockCocktailService.createSampleCocktail(id: "11002")
        ]
        
        cacheService.cachePopularCocktails(firstCocktails)
        let firstCached = cacheService.getCachedPopularCocktails()
        XCTAssertEqual(firstCached?.count, 1)
        
        cacheService.cachePopularCocktails(secondCocktails)
        let secondCached = cacheService.getCachedPopularCocktails()
        XCTAssertEqual(secondCached?.count, 2)
    }
    
    func testCorruptedCacheData() {
        UserDefaults.standard.set("invalid data".data(using: .utf8), forKey: cacheKey)
        UserDefaults.standard.set(Date().addingTimeInterval(24 * 60 * 60).timeIntervalSince1970, forKey: cacheExpirationKey)
        
        let cachedCocktails = cacheService.getCachedPopularCocktails()
        XCTAssertNil(cachedCocktails)
    }
} 
