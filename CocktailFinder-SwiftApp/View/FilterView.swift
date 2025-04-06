import SwiftUI

struct FilterCategory1: Identifiable {
    let id = UUID()
    var name: String
    var options: [FilterOption]
}

struct FilterOption: Identifiable {
    let id = UUID()
    var name: String
    var isSelected: Bool = false
}

class FilterManager: ObservableObject {
    @Published var categories: [FilterCategory1]
    @Published var selectedOptionID: UUID?
    
    init(categories: [FilterCategory1]) {
        self.categories = categories
    }
    
    func selectOption(_ optionID: UUID) {
        resetAllSelections()
        selectedOptionID = optionID
        
        for i in categories.indices {
            for j in categories[i].options.indices {
                if categories[i].options[j].id == optionID {
                    categories[i].options[j].isSelected = true
                }
            }
        }
    }
    
    private func resetAllSelections() {
        selectedOptionID = nil
        for i in categories.indices {
            for j in categories[i].options.indices {
                categories[i].options[j].isSelected = false
            }
        }
    }
}

import SwiftUI

struct FilterView: View {
    @StateObject private var filterManager = FilterManager(
        categories: [
            FilterCategory1(
                name: "Алкоголь",
                options: [
                    FilterOption(name: "Алкогольный"),
                    FilterOption(name: "Безалкогольный")
                ]
            ),
            FilterCategory1(
                name: "По тегам",
                options: [
                    FilterOption(name: "Тэг 1"),
                    FilterOption(name: "Тэг 2")
                ]
            ),
            FilterCategory1(
                name: "По типу стакана",
                options: [
                    FilterOption(name: "Стакан 1"),
                    FilterOption(name: "Стакан 2")
                ]
            ),
            FilterCategory1(
                name: "По ингредиентам",
                options: [
                    FilterOption(name: "Ингредиент 1"),
                    FilterOption(name: "Ингредиент 2")
                ]
            )
        ]
    )
    var body: some View {
           NavigationStack {
               List {
                   ForEach($filterManager.categories) { $category in
                       DisclosureGroup(
                           content: {
                               ForEach(category.options) { option in
                                   FilterOptionRow(
                                       title: option.name,
                                       isSelected: option.id == filterManager.selectedOptionID
                                   ) {
                                       filterManager.selectOption(option.id)
                                   }
                               }
                           },
                           label: {
                               Text(category.name)
                                   .font(.headline)
                           }
                       )
                   }
               }
               .listStyle(.insetGrouped)
           }
       }
   }

struct FilterOptionRow: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .foregroundColor(isSelected ? .blue : .primary)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                }
            }
        }
        .buttonStyle(.plain)
    }
}


struct FilterView_Previews: PreviewProvider {
    static var previews: some View {
        FilterView()
    }
}
