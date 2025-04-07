import SwiftUI
import SDWebImageSwiftUI

struct CocktailCardView: View {
    let cocktail: Cocktail
    
    var body: some View {
        VStack(spacing: 8) {
            // Фото коктейля
            WebImage(url: URL(string: cocktail.thumbnail))
                .resizable()
                .indicator(.activity)
                .transition(.fade(duration: 0.5))
                .scaledToFill()
                .frame(width: 160, height: 160)
                .clipped()
                .cornerRadius(4)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
            // Название коктейля
            Text(cocktail.name)
                .font(.system(size: 22, weight: .medium))
                .lineLimit(1)
                .frame(width: 160, alignment: .center)
            
            // Кнопка "Рецепт"
            NavigationLink(destination: RecipeView(drinkId: cocktail.id)) {
                Text("Рецепт")
                    .font(.system(size: 16, weight: .medium))
                    .frame(width: 150, height: 36)
                    .foregroundColor(.white)
                    .background(Color.orange)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(15)
    }
}

// Превью для CocktailCardView с загрузкой реальных данных
struct CocktailCardView_Previews: PreviewProvider {
    static var previews: some View {
        CocktailCardPreview()
    }
}

// Вспомогательное превью с загрузкой данных
struct CocktailCardPreview: View {
    @State private var cocktail: Cocktail?
    @State private var isLoading = false
    @State private var error: Error?
    
    private let apiService = APIService.shared
    
    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView("Загрузка...")
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
                    Text("Нет данных")
                        .padding()
                }
            }
        }
        .onAppear {
            loadCocktailData()
        }
    }
    
    private func loadCocktailData() {
        isLoading = true
        error = nil
        
        Task {
            do {
                let cocktails = try await apiService.fetchCocktailByName("Margarita")
                
                DispatchQueue.main.async {
                    if let firstCocktail = cocktails.first {
                        self.cocktail = firstCocktail
                    }
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

// Вспомогательный класс для создания моковых данных
//struct MockData {
//    static var sampleCocktail: Cocktail {
//        // Создаем ингредиенты Маргариты
//        let ingredients = [
//            Cocktail.Ingredient(name: "Tequila", measure: "1 1/2 oz"),
//            Cocktail.Ingredient(name: "Triple sec", measure: "1/2 oz"),
//            Cocktail.Ingredient(name: "Lime juice", measure: "1 oz"),
//            Cocktail.Ingredient(name: "Salt", measure: "")
//        ]
//        
//        // Используем конструктор, который точно соответствует модели данных
//        return Cocktail(
//            id: "11007",
//            name: "Margarita",
//            tags: "IBA,ContemporaryClassic",
//            category: "Ordinary Drink",
//            alcoholic: "Alcoholic",
//            glass: "Cocktail glass",
//            instructions: "Rub the rim of the glass with the lime slice to make the salt stick to it.",
//            thumbnail: "https://www.thecocktaildb.com/images/media/drink/5noda61589575158.jpg",
//            ingredients: ingredients,
//            isFavorite: false
//        )
//    }
//}
//
