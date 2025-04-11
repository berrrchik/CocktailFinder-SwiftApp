import SwiftUI

struct FavoriteCoctailsView: View {
    @State private var favorites: [Cocktail] = []
    private let favoritesService = FavoritesService.shared
    
    var body: some View {
        NavigationStack {
            if favorites.isEmpty {
                VStack(spacing: 20) {
                    Text("Здесь будут ваши любимые коктейли")
                        .font(.title3)
                    Image(systemName: "heart.fill")
                        .font(.title)
                        .foregroundColor(.blue)
                }
            } else {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 170), spacing: 16)], spacing: 16) {
                        ForEach(favorites) { cocktail in
                            CocktailCardView(cocktail: cocktail)
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Избранное")
        .onAppear {
            loadFavorites()
        }
    }
    
    private func loadFavorites() {
        favorites = favoritesService.getFavorites()
    }
}

#Preview {
    FavoriteCoctailsView()
}
