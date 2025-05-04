import Testing
@testable import CocktailFinder_SwiftApp
import XCTest

struct CocktailFinder_SwiftAppTests {

    @Test func example() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    }

}

final class CocktailModelTests: XCTestCase {
    
    var sampleCocktailJSON: Data!
    
    override func setUpWithError() throws {
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
        
        sampleCocktailJSON = jsonString.data(using: .utf8)!
    }
    
    override func tearDownWithError() throws {
        sampleCocktailJSON = nil
    }
    
    func testCocktailDecoding() throws {
        let decoder = JSONDecoder()
        let cocktail = try decoder.decode(Cocktail.self, from: sampleCocktailJSON)
        
        XCTAssertEqual(cocktail.id, "11000")
        XCTAssertEqual(cocktail.name, "Mojito")
        XCTAssertEqual(cocktail.category, "Cocktail")
        XCTAssertEqual(cocktail.alcoholic, "Alcoholic")
        XCTAssertEqual(cocktail.glass, "Highball glass")
        
        XCTAssertEqual(cocktail.ingredients.count, 5)
        XCTAssertEqual(cocktail.ingredients[0].name, "Light rum")
        XCTAssertEqual(cocktail.ingredients[0].measure, "2-3 oz")
    }
    
    func testIngredientEquality() throws {
        let ingredient1 = Cocktail.Ingredient(name: "Vodka", measure: "1 oz")
        let ingredient2 = Cocktail.Ingredient(name: "Vodka", measure: "1 oz")
        let ingredient3 = Cocktail.Ingredient(name: "Rum", measure: "1 oz")
        
        XCTAssertEqual(ingredient1, ingredient2)
        XCTAssertNotEqual(ingredient1, ingredient3)
    }
}
