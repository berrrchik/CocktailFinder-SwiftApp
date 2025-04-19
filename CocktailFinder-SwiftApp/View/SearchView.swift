import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                SearchBar(text: $viewModel.searchText, 
                         isSearchBarFocused: $viewModel.isSearchBarFocused,
                         onSearch: {
                    viewModel.performSearch()
                }, onClear: {
                    viewModel.clearSearchResults()
                })
                .padding(.horizontal)
                .padding(.vertical, 8)
                
                ScrollView {
                    VStack {
                        if viewModel.isLoading {
                            LoadingView()
                        } else if !viewModel.isSearchBarFocused && !viewModel.hasSearched {
                            popularCocktailsView
                        } else if !viewModel.hasSearched {
                            EmptySearchView()
                        } else if viewModel.searchResults.isEmpty || viewModel.error != nil {
                            NotFoundView()
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
    @Binding var isSearchBarFocused: Bool
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
                    isSearchBarFocused = newValue
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

struct LoadingView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "hourglass.circle")
                .font(.system(size: 70))
                .foregroundColor(.gray)
            
            Text("Идёт поиск")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Пожалуйста, подождите")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.vertical, 60)
    }
}

struct EmptySearchView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "wineglass")
                .font(.system(size: 70))
                .foregroundColor(.gray)
            
            Text("Найдите свой коктейль")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Введите название коктейля в поисковую строку")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.vertical, 60)
    }
}

struct NotFoundView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "magnifyingglass.circle")
                .font(.system(size: 70))
                .foregroundColor(.gray)
            
            Text("Коктейль не найден")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Попробуйте изменить параметры поиска или поищите другой коктейль")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.vertical, 60)
    }
}

#Preview {
    SearchView()
}
