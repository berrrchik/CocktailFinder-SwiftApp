import Foundation
import SwiftUI

class FilterOption: Identifiable, ObservableObject {
    let id = UUID()
    var name: String
    @Published var isSelected: Bool = false
    
    init(name: String, isSelected: Bool = false) {
        self.name = name
        self.isSelected = isSelected
    }
}

