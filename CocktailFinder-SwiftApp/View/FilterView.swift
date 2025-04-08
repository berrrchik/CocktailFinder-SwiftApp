import SwiftUI
import SDWebImageSwiftUI

class FilterManager: ObservableObject {
    let drinkId: String
    private let apiService = APIService.shared
    
    @Published var categories: [FilterCategory]
    @Published var filteredCocktails: [Cocktail] = []
    @Published var isLoading = false
    @Published var error: Error?
    @Published var selectedFilterName: String = ""
    
    init(categories: [FilterCategory], drinkId: String = "11007") {
        self.categories = categories
        self.drinkId = drinkId
    }
    
    func selectOption(_ optionID: UUID) {
        resetAllSelections()
        
        for categoryIndex in categories.indices {
            if let index = categories[categoryIndex].options.firstIndex(where: { $0.id == optionID }) {
                categories[categoryIndex].options[index].isSelected = true
                selectedFilterName = categories[categoryIndex].options[index].name
                loadFilteredCocktails(type: categories[categoryIndex].type, value: categories[categoryIndex].options[index].name)
                break
            }
        }
    }
    
    private func resetAllSelections() {
        for categoryIndex in categories.indices {
            for i in categories[categoryIndex].options.indices {
                categories[categoryIndex].options[i].isSelected = false
            }
        }
    }
    
    func loadFilteredCocktails(type: FilterType, value: String) {
        isLoading = true
        error = nil
        filteredCocktails = []
        
        Task {
            do {
                print("Загрузка коктейлей с фильтром: тип=\(type), значение=\(value)")
                let results = try await apiService.fetchCocktailsByFilter(type: type, value: value)
                print("Загружено коктейлей: \(results.count)")
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.filteredCocktails = results
                    self.isLoading = false
                    print("Обновлены filteredCocktails, количество: \(self.filteredCocktails.count)")
                }
            } catch {
                print("Ошибка при загрузке коктейлей: \(error)")
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.error = error
                    self.isLoading = false
                }
            }
        }
    }
}

struct FilterView: View {
    @StateObject private var viewModel = FilterViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Загрузка...")
                } else if let error = viewModel.error {
                    VStack {
                        Text("Ошибка загрузки")
                            .font(.headline)
                        Text(error.localizedDescription)
                            .font(.subheadline)
                            .foregroundColor(.red)
                        Button("Повторить") {
                            Task {
                                await viewModel.loadFilterOptions()
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding()
                } else if viewModel.filterManager.categories.isEmpty {
                    Text("Нет доступных фильтров")
                        .font(.headline)
                } else {
                    VStack {
                        List {
                            Section {
                                ForEach(viewModel.filterManager.categories) { category in
                                    DisclosureGroup(
                                        content: {
                                            ForEach(category.options) { option in
                                                FilterOptionRow(
                                                    option: option,
                                                    action: {
                                                        viewModel.filterManager.selectOption(option.id)
                                                    }
                                                )
                                            }
                                        },
                                        label: {
                                            Text(category.name)
                                                .font(.headline)
                                        }
                                    )
                                }
                            }
                            
                            Section {
                                ResultsSection(filterManager: viewModel.filterManager)
                            }
                        }
                        .listStyle(.insetGrouped)
                    }
                }
            }
            .navigationTitle("Фильтр коктейлей")
        }
        .task {
            await viewModel.loadFilterOptions()
        }
    }
}

struct ResultsSection: View {
    @ObservedObject var filterManager: FilterManager
    
    var body: some View {
        Group {
            if !filterManager.selectedFilterName.isEmpty {
                HStack {
                    Text("Результаты для \"\(filterManager.selectedFilterName)\"")
                        .font(.headline)
                    
                    Spacer()
                    
                    Text("\(filterManager.filteredCocktails.count)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            if filterManager.isLoading {
                ProgressView("Загрузка коктейлей...")
                    .frame(maxWidth: .infinity)
            } else if let error = filterManager.error {
                VStack {
                    Text("Ошибка загрузки коктейлей")
                        .font(.headline)
                    Text(error.localizedDescription)
                        .font(.subheadline)
                        .foregroundColor(.red)
                }
                .padding()
            } else if !filterManager.filteredCocktails.isEmpty {
                ForEach(filterManager.filteredCocktails) { cocktail in
                    NavigationLink(destination: RecipeView(drinkId: cocktail.id)) {
                        CocktailListItemView(
                            cocktail: cocktail,
                            filterTag: filterManager.selectedFilterName
                        )
                    }
                }
            }
        }
        .headerProminence(.increased)
    }
}


struct CocktailListItemView: View {
    let cocktail: Cocktail
    let filterTag: String
    
    var body: some View {
        HStack(spacing: 15) {
            WebImage(url: URL(string: cocktail.thumbnail))
                .resizable()
                .scaledToFill()
                .frame(width: 50, height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 6))
            
            VStack(alignment: .leading, spacing: 5) {
                Text(cocktail.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                HStack(spacing: 5) {
                    Image(systemName: "wineglass")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(filterTag)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

class FilterViewModel: ObservableObject {
    @Published var filterManager: FilterManager
    private let apiService = APIService.shared
    @Published var isLoading = false
    @Published var error: Error?
    
    init() {
        self.filterManager = FilterManager(categories: [])
        print("FilterViewModel initialized")
    }
    
    @MainActor
    func loadFilterOptions() async {
        isLoading = true
        print("Starting to load filter options")
        do {
            let categories = try await apiService.fetchFilterOptions()
            print("Received categories: \(categories)")
            filterManager.categories = categories
        } catch {
            print("Error loading filter options: \(error)")
            self.error = error
        }
        isLoading = false
    }
}

struct FilterOptionRow: View {
    @ObservedObject var option: FilterOption
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            HStack {
                Text(option.name)
                    .foregroundColor(option.isSelected ? .blue : .primary)
                
                Spacer()
                
                if option.isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                }
            }
            .contentShape(Rectangle())
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct FilterView_Previews: PreviewProvider {
    static var previews: some View {
        FilterView()
    }
}
