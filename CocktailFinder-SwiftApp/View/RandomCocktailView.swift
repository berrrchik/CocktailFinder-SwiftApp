import SwiftUI

struct RandomCocktailView: View {
    @State private var cocktail: Cocktail?
    @State private var isLoading = false
    @State private var error: Error?
    
    private let apiService = APIService.shared
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Случайный коктейль")
                    .font(.title)
                
                Button {
                    fetchRandomCocktail()
                } label: {
                    Label("Попытать удачу", systemImage: "dice")
                }
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .padding(.vertical, 10)
                .padding(.horizontal, 20)
                .background(Color.blue)
                .cornerRadius(14)
                
                if isLoading {
                    ProgressView("Ищем случайный коктейль...")
                        .padding()
                } else if let error = error {
                    VStack {
                        Text("Ошибка загрузки")
                            .font(.headline)
                        Text(error.localizedDescription)
                            .foregroundColor(.red)
                    }
                    .padding()
                } else if let cocktail = cocktail {
                    CocktailCardView(cocktail: cocktail)
                        .padding()
                } else {
                    Text("Нажмите кнопку, чтобы получить случайный коктейль")
                        .multilineTextAlignment(.center)
                        .padding()
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
            .padding()
        }
    }
    
    private func fetchRandomCocktail() {
        isLoading = true
        error = nil
        
        Task {
            do {
                let randomCocktail = try await apiService.fetchRandomCocktail()
                
                DispatchQueue.main.async {
                    self.cocktail = randomCocktail
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
    RandomCocktailView()
}
