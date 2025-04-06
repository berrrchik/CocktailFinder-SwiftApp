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
}
