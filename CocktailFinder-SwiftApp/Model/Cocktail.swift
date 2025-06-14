import Foundation

struct Cocktail: Codable, Identifiable {
    let id: String
    let name: String
    let tags: String?
    let category: String
    let alcoholic: String
    let glass: String
    let instructions: String
    let thumbnail: String
    let ingredients: [Ingredient]
    var isFavorite: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case id = "idDrink"
        case name = "strDrink"
        case tags = "strTags"
        case category = "strCategory"
        case alcoholic = "strAlcoholic"
        case glass = "strGlass"
        case instructions = "strInstructions"
        case thumbnail = "strDrinkThumb"
    }
    
    struct Ingredient: Codable, Hashable {
        let name: String
        let measure: String
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        tags = try container.decodeIfPresent(String.self, forKey: .tags)
        category = try container.decode(String.self, forKey: .category)
        alcoholic = try container.decode(String.self, forKey: .alcoholic)
        glass = try container.decode(String.self, forKey: .glass)
        instructions = try container.decode(String.self, forKey: .instructions)
        thumbnail = try container.decode(String.self, forKey: .thumbnail)
        
        var ingredients = [Ingredient]()
        let dynamicContainer = try decoder.container(keyedBy: DynamicCodingKeys.self)
        
        for i in 1...15 {
            guard let ingredientKey = DynamicCodingKeys(stringValue: "strIngredient\(i)"),
                  let measureKey = DynamicCodingKeys(stringValue: "strMeasure\(i)") else {
                continue
            }
            
            if let ingredient = try dynamicContainer.decodeIfPresent(String.self, forKey: ingredientKey),
               !ingredient.isEmpty,
               let measure = try dynamicContainer.decodeIfPresent(String.self, forKey: measureKey) {
                ingredients.append(Ingredient(name: ingredient, measure: measure))
            }
        }
        self.ingredients = ingredients
    }
}

struct DynamicCodingKeys: CodingKey {
    var stringValue: String
    init?(stringValue: String) {
        self.stringValue = stringValue
    }
    
    var intValue: Int? { nil }
    init?(intValue: Int) { nil }
}
