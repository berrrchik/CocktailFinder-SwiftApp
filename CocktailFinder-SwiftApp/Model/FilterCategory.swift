import Foundation

enum FilterType {
    case category
    case glass
    case ingredient
    case alcoholic
}

struct FilterCategory: Identifiable {
    let id = UUID()
    let type: FilterType
    let name: String
    let options: [String]
}
