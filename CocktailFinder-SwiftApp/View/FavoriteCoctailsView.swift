import SwiftUI

struct FavoriteCoctailsView: View {
    @StateObject private var viewModel = FavoritesViewModel()
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isFavoriteEmpty() {
                    VStack(spacing: 20) {
                        Spacer()
                        
                        Image(systemName: "heart.fill")
                            .font(.system(size: 70))
                            .foregroundColor(.blue)
                        
                        Text("Здесь будут ваши любимые коктейли")
                            .font(.title2)
                            .multilineTextAlignment(.center)
                            .padding()
                        
                        Spacer()
                    }
                } else {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            ForEach(viewModel.favorites) { cocktail in
                                NavigationLink(destination: RecipeView(drinkId: cocktail.id)) {
                                    CocktailCardView(cocktail: cocktail)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Избранное")
            .onAppear {
                viewModel.loadFavorites()
            }
        }
    }
}

#Preview {
    FavoriteCoctailsView()
}
