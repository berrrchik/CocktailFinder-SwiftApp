import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                SearchBar(text: $viewModel.searchText)
                    .padding(.horizontal)
                
                if viewModel.isLoading {
                    ProgressView("Загрузка...")
                        .padding()
                } else if let error = viewModel.error {
                    Text("Ошибка: \(error.localizedDescription)")
                        .foregroundColor(.red)
                        .padding()
                } else if !viewModel.searchText.isEmpty && viewModel.searchResults.isEmpty {
                    Text("Не найдено коктейлей")
                        .padding()
                    Spacer()
                } else {
                    content
                }
            }
            .navigationTitle("Поиск коктейлей")
        }
    }
    
    private var content: some View {
        ScrollView {
            if !viewModel.searchText.isEmpty {
                resultsGrid(cocktails: viewModel.searchResults)
            } else {
                popularSection
            }
        }
    }
    
    private var popularSection: some View {
        VStack(alignment: .leading) {
            Text("Популярные коктейли")
                .font(.title2)
                .padding(.horizontal)
                .padding(.top)
                .fontWeight(.semibold)
            
            resultsGrid(cocktails: viewModel.popularCocktails)
        }
    }
    
    private func resultsGrid(cocktails: [Cocktail]) -> some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
            ForEach(cocktails) { cocktail in
                NavigationLink(destination: RecipeView(drinkId: cocktail.id)) {
                    CocktailCardView(cocktail: cocktail)
                }
            }
        }
        .padding()
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            TextField("Введите название...", text: $text)
                .padding(8)
                .padding(.horizontal, 25)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 8)
                        
                        if !text.isEmpty {
                            Button(action: {
                                self.text = ""
                            }) {
                                Image(systemName: "multiply.circle.fill")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 8)
                            }
                        }
                    }
                )
        }
    }
}

#Preview {
    SearchView()
}
