import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                SearchBar(text: $viewModel.searchText, 
                         isSearching: $viewModel.isSearchBarFocused,
                         onSearch: {
                    viewModel.performSearch()
                }, onClear: {
                    viewModel.clearSearchResults()
                })
                .padding(.horizontal)
                .padding(.vertical, 8)
                
                VStack(alignment: .leading, spacing: 8) {
                
                    AlphabetCarouselView(selectedLetter: viewModel.selectedLetter) { letter in
                        viewModel.searchCocktailsByLetter(letter)
                    }
                }
                
                if viewModel.selectedLetter != nil {
                    Text("Коктейли на букву \(viewModel.selectedLetter?.uppercased() ?? "")")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemGray6))
                }
                
                ScrollView {
                    VStack {
                        if viewModel.isLoading {
                            StateView(
                                iconName: "hourglass.circle",
                                title: "Идёт поиск",
                                description: "Пожалуйста, подождите"
                            )
                        } else if !viewModel.isSearchBarFocused && !viewModel.hasSearched {
                            popularCocktailsView
                        } else if !viewModel.hasSearched {
                            StateView(
                                iconName: "wineglass",
                                title: "Найдите свой коктейль",
                                description: "Введите название коктейля в поисковую строку"
                            )
                        } else if viewModel.searchResults.isEmpty || viewModel.error != nil {
                            StateView(
                                iconName: "magnifyingglass.circle",
                                title: "Коктейль не найден",
                                description: "Попробуйте изменить параметры поиска или поищите другой коктейль"
                            )
                        } else {
                            resultsGrid(cocktails: viewModel.searchResults)
                        }
                    }
                }
            }
            .navigationTitle("Поиск коктейлей")
        }
    }
    
    private var popularCocktailsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Популярные коктейли")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.horizontal)
            
            resultsGrid(cocktails: viewModel.popularCocktails)
        }
        .padding(.top)
    }
    
    private func resultsGrid(cocktails: [Cocktail]) -> some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
            ForEach(cocktails) { cocktail in
                NavigationLink(destination: RecipeView(drinkId: cocktail.id)) {
                    CocktailCardView(cocktail: cocktail)
                }
            }
        }
        .padding(.horizontal)
    }
}

struct SearchBar: View {
    @Binding var text: String
    @Binding var isSearching: Bool
    @FocusState private var isFocused: Bool
    var onSearch: () -> Void
    var onClear: () -> Void
    
    var body: some View {
        HStack {
            TextField("Введите название...", text: $text)
                .padding(8)
                .padding(.horizontal, 25)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .focused($isFocused)
                .onChange(of: isFocused) { newValue in
                    isSearching = newValue
                }
                .onSubmit {
                    isFocused = false
                    onSearch()
                }
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 8)
                        
                        if !text.isEmpty {
                            Button(action: {
                                self.text = ""
                                onClear()
                            }) {
                                Image(systemName: "multiply.circle.fill")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 8)
                            }
                        }
                    }
                )
            
            Button(action: {
                isFocused = false
                onSearch()
            }) {
                Text("Поиск")
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
    }
}

#Preview {
    SearchView()
}
