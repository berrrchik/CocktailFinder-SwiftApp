import SwiftUI
import SDWebImageSwiftUI

class FilterManager: ObservableObject {
    let drinkId: String
    
    @Published var categories: [FilterCategory]
    @Published var filteredCocktails: [Cocktail] = []
    @Published var isLoading = false
    @Published var loadingProgress: String = ""
    @Published var error: Error?
    @Published var selectedFilterName: String = ""
    @Published var useCache: Bool = true
    
    weak var viewModel: FilterViewModel?
    
    private var currentTask: Task<Void, Never>?
    
    static let shared = FilterManager(categories: [])
    
    init(categories: [FilterCategory], drinkId: String = "11007") {
        self.categories = categories
        self.drinkId = drinkId
        
        print("FilterManager инициализирован: кеширование \(useCache ? "включено" : "выключено")")
    }
    
    deinit {
        cancelLoading()
    }
    
    func selectOption(_ optionID: UUID) {
        if let viewModel = viewModel {
            viewModel.selectFilterOption(optionID)
        }
    }
    
    func cancelLoading() {
        currentTask?.cancel()
        currentTask = nil
        
        viewModel?.cancelLoading()
    }
    
    func retryLastRequest() {
        viewModel?.retryLastRequest()
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
                                                        viewModel.selectFilterOption(option.id)
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
                                ResultsSection(filterManager: viewModel.filterManager, viewModel: viewModel)
                            }
                        }
                        .listStyle(.insetGrouped)
                    }
                }
            }
            .navigationTitle("Фильтр коктейлей")
        }
        .task {
            if viewModel.filterManager.categories.isEmpty {
                await viewModel.loadFilterOptions()
            }
        }
        .onDisappear {
            viewModel.cancelLoading()
        }
    }
}

struct ResultsSection: View {
    @ObservedObject var filterManager: FilterManager
    let viewModel: FilterViewModel
    
    var body: some View {
        Group {
            contentView
        }
        .headerProminence(.increased)
        .onDisappear {
            viewModel.cancelLoading()
        }
    }
    
    @ViewBuilder
    private var contentView: some View {
        if !filterManager.selectedFilterName.isEmpty {
            VStack(spacing: 0) {
                HStack {
                    Text("Результаты для \"\(filterManager.selectedFilterName)\"")
                        .font(.headline)
                    
                    Spacer()
                    
                    Text("\(filterManager.filteredCocktails.count)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        
        if filterManager.isLoading {
            VStack(spacing: 10) {
                ProgressView("Загрузка коктейлей...")
                    .frame(maxWidth: .infinity)
                
                if !filterManager.loadingProgress.isEmpty {
                    Text(filterManager.loadingProgress)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical)
        } else if let error = filterManager.error {
            VStack {
                Text("Ошибка загрузки коктейлей")
                    .font(.headline)
                Text(error.localizedDescription)
                    .font(.subheadline)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                Button("Повторить") {
                    retryLoading()
                }
                .buttonStyle(.bordered)
            }
            .padding()
        } else if !filterManager.filteredCocktails.isEmpty {
            ForEach(filterManager.filteredCocktails) { cocktail in
                NavigationLink(destination: RecipeView(cocktail: cocktail)) {
                    CocktailListItemView(
                        cocktail: cocktail,
                        filterTag: filterManager.selectedFilterName
                    )
                }
            }
        } else if !filterManager.selectedFilterName.isEmpty && !filterManager.isLoading {
            Text("Нет коктейлей для выбранного фильтра")
                .foregroundColor(.secondary)
                .padding()
        }
    }
    
    private func retryLoading() {
        viewModel.retryLastRequest()
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
