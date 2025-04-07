import Foundation

enum FilterType {
    case category
    case glass
    case ingredient
    case alcoholic
}

class FilterCategory: Identifiable, ObservableObject {
    let id = UUID()
    let type: FilterType
    let name: String
    @Published var options: [FilterOption] 
    
    init(type: FilterType, name: String, options: [FilterOption]) {
        self.type = type
        self.name = name
        self.options = options
    }
}
