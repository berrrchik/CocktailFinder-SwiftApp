import SwiftUI

struct RandomCocktailView: View {
    @StateObject private var viewModel = RandomCocktailViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Загрузка случайного коктейля...")
                        .padding()
                } else if let error = viewModel.error {
                    errorView
                } else if let cocktail = viewModel.cocktail {
                    ScrollView {
                        VStack(spacing: 20) {
                            Text("Сегодня попробуйте")
                                .font(.headline)
                                .padding(.top)
                            
                            Text(cocktail.name)
                                .font(.title)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                            
                            NavigationLink(destination: RecipeView(drinkId: cocktail.id)) {
                                VStack(spacing: 20) {
                                    CocktailCardView(cocktail: cocktail, imageHeight: 350)
                                        .frame(width: 350)
                                }
                                .padding(.horizontal)
                            }
                            
                            Button {
                                viewModel.loadRandomCocktail()
                            } label: {
                                HStack {
                                    Image(systemName: "arrow.2.squarepath")
                                    Text("Другой коктейль")
                                }
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                            }
                        }
                    }
                } else {
                    Text("Не удалось загрузить случайный коктейль")
                        .padding()
                }
            }
            .navigationTitle("Случайный коктейль")
        }
    }
    
    private var errorView: some View {
        VStack {
            Text("Ошибка загрузки")
                .font(.headline)
            
            Text(viewModel.error?.localizedDescription ?? "Неизвестная ошибка")
                .multilineTextAlignment(.center)
                .padding()
            
            Button("Повторить") {
                viewModel.loadRandomCocktail()
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
}

#Preview {
    RandomCocktailView()
}
