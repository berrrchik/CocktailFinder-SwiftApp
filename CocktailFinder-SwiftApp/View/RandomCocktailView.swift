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
                                HStack(spacing: 8) {
                                    Image(systemName: "arrow.clockwise")
                                        .font(.system(size: 16, weight: .medium))
                                    Text("Другой коктейль")
                                        .font(.system(size: 16, weight: .medium))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(Color.customOrange)
                                .cornerRadius(12)
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
