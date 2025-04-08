import SwiftUI
 
struct SearchView: View {
    @State private var searchText: String = ""
    @State private var cocktails: [Cocktail] = []
    @State private var isLoading = false
    @State private var error: Error?
    @State private var isSearching = false
    
    private let apiService = APIService.shared
    private let popularCocktailIds = ["11000", "11001", "11002", "11003", "11004", "11005", "11006", "11007"]

    var body: some View {
        NavigationStack {
            VStack {
                if isLoading {
                    ProgressView("Ищем коктейли...")
                } else if let error = error {
                    VStack {
                        Text("Ошибка поиска")
                            .font(.headline)
                        Text(error.localizedDescription)
                            .foregroundColor(.red)
                        Button("Повторить") {
                            if isSearching {
                                searchCocktails()
                            } else {
                                loadPopularCocktails()
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                } else if cocktails.isEmpty {
                    Text(isSearching ? "Коктейли не найдены" : "Загрузка популярных коктейлей...")
                        .font(.headline)
                } else {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 170), spacing: 16)], spacing: 16) {
                            ForEach(cocktails) { cocktail in
                                CocktailCardView(cocktail: cocktail)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle(isSearching ? "Поиск: \(searchText)" : "Популярные коктейли")
            .searchable(text: $searchText, prompt: "Поиск коктейлей")
            .onChange(of: searchText) { newValue in
                if newValue.isEmpty {
                    isSearching = false
                    loadPopularCocktails()
                } else {
                    isSearching = true
                    searchCocktails()
                }
            }
            .onAppear {
                if searchText.isEmpty {
                    loadPopularCocktails()
                }
            }
        }
    }
    
    private func searchCocktails() {
        guard !searchText.isEmpty else { return }
        
        isLoading = true
        error = nil
        
        Task {
            do {
                let results = try await apiService.fetchCocktailByName(searchText)
                DispatchQueue.main.async {
                    self.cocktails = results
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.error = error
                    self.isLoading = false
                }
            }
        }
    }
    
    private func loadPopularCocktails() {
        guard searchText.isEmpty else { return }
        
        isLoading = true
        error = nil
        cocktails = []
        
        Task {
            do {
                var popularCocktails: [Cocktail] = []
                for id in popularCocktailIds {
                    if let cocktail = try? await apiService.fetchCocktailById(id) {
                        popularCocktails.append(cocktail)
                    }
                }
                
                DispatchQueue.main.async {
                    self.cocktails = popularCocktails
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.error = error
                    self.isLoading = false
                }
            }
        }
    }
}

#Preview {
    SearchView()
}
