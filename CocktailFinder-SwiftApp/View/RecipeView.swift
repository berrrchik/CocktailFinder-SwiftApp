import SwiftUI
import SDWebImageSwiftUI

struct RecipeView: View {
    let drinkId: String
    @State private var cocktail: Cocktail?
    @State private var isFavorite: Bool = false
    @State var isLoading = false
    @State var error: Error?
    
    @Environment(\.dismiss) var dismiss
    
    private let apiService = APIService.shared
    private let favoritesService = FavoritesService.shared
    
    init(drinkId: String = "11007") {
        self.drinkId = drinkId
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if isLoading {
                    ProgressView("Загрузка...")
                        .padding()
                } else if let error = error {
                    errorView
                } else if let cocktail = cocktail {
                    VStack(spacing: 0) {
                        HStack(alignment: .top, spacing: 20) {
                            WebImage(url: URL(string: cocktail.thumbnail))
                                .resizable()
                                .scaledToFit()
                                .frame(width: 120, height: 120)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            
                            VStack(alignment: .leading, spacing: 10) {
                                Text(cocktail.name)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                if let tags = cocktail.tags {
                                    FlowLayout(spacing: 8) {
                                        Image(systemName: "tag")
                                        ForEach(tags.components(separatedBy: ","), id: \.self) { tag in
                                            Text(tag)
                                                .font(.caption)
                                                .padding(.horizontal, 5)
                                                .padding(.vertical, 5)
                                                .background(Color.gray.opacity(0.2))
                                                .cornerRadius(15)
                                        }
                                    }
                                }
                                HStack{
                                    Image(systemName: "wineglass")
                                    Text(cocktail.alcoholic)
                                        .font(.caption)
                                        .padding(.horizontal, 5)
                                        .padding(.vertical, 5)
                                        .background(Color.gray.opacity(0.2))
                                        .cornerRadius(15)
                                }
                            }
                            
                            Spacer()
                        }
                        .padding()
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Ингредиенты: \(cocktail.ingredients.count)")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            VStack(alignment: .leading, spacing: 5) {
                                ForEach(Array(cocktail.ingredients.enumerated()), id: \.element) { index, ingredient in
                                    HStack {
                                        Text("\(index + 1).")
                                        Text(ingredient.name)
                                        Spacer()
                                        Text(ingredient.measure)
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
                        .padding(.vertical)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Инструкция")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            Text("Сервировка: \(cocktail.glass)")
                                .padding(.horizontal)
                            
                            Text(cocktail.instructions)
                                .padding(.horizontal)
                                .padding(.top, 5)
                            
                        }
                        .padding(.vertical)
                    }
                } else {
                    Text("Нет данных о коктейле")
                        .padding()
                }
            }
            .navigationTitle("Рецепт")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 3) {
                            Image(systemName: "chevron.left")
                            Text("Назад")
                        }
                        .foregroundColor(.blue)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isFavorite.toggle()
                        if isFavorite {
                            favoritesService.addToFavorites(cocktail!)
                        } else {
                            favoritesService.removeFromFavorites(cocktail!)
                        }
                    }) {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .foregroundColor(isFavorite ? .red : .black)
                    }
                }
            }
        }
        .onAppear {
            loadCocktailData()
        }
    }
    
    private var errorView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 70))
                .foregroundColor(.orange)
                .padding()
            
            Text("Не получилось загрузить рецепт")
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text("Проверьте подключение к интернету или попробуйте загрузить позже")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button {
                retryLoadingCocktail()
            } label: {
                Text("Повторить запрос")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: 250)
                    .background(Color.blue)
                    .cornerRadius(10)
                    .shadow(radius: 3)
            }
            .padding(.top, 10)
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
    }
    
    private func retryLoadingCocktail() {
        loadCocktailData()
    }
    
    func loadCocktailData() {
        isLoading = true
        error = nil
        
        Task {
            do {
                let loadedCocktail = try await apiService.fetchCocktailById(drinkId)
                
                DispatchQueue.main.async {
                    self.cocktail = loadedCocktail
                    self.isFavorite = favoritesService.isFavorite(loadedCocktail)
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

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        return arrangeSubviews(sizes: sizes, proposal: proposal).size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        let offsets = arrangeSubviews(sizes: sizes, proposal: proposal).offsets
        
        for (offset, subview) in zip(offsets, subviews) {
            subview.place(at: CGPoint(x: bounds.minX + offset.x, y: bounds.minY + offset.y), proposal: .unspecified)
        }
    }
    
    private func arrangeSubviews(sizes: [CGSize], proposal: ProposedViewSize) -> (offsets: [CGPoint], size: CGSize) {
        let maxWidth = proposal.width ?? .infinity
        var offsets: [CGPoint] = []
        var currentPosition = CGPoint.zero
        var maxY: CGFloat = 0
        
        for size in sizes {
            if currentPosition.x + size.width > maxWidth {
                currentPosition.x = 0
                currentPosition.y = maxY + spacing
            }
            
            offsets.append(currentPosition)
            currentPosition.x += size.width + spacing
            maxY = max(maxY, currentPosition.y + size.height)
        }
        
        return (offsets, CGSize(width: maxWidth, height: maxY))
    }
}

struct RecipeView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            RecipeView_MargaritaPreview()
                .previewDisplayName("Стандартный вид")
            
            RecipeView_ErrorPreview()
                .previewDisplayName("Экран ошибки")
        }
    }
}

struct RecipeView_MargaritaPreview: View {
    var body: some View {
        let view = RecipeView(drinkId: "11007")
        return view
    }
}

struct RecipeView_ErrorPreview: View {
    var body: some View {
        let view = RecipeView(drinkId: "invalid_id")
        
        DispatchQueue.main.async {
            view.error = NSError(domain: "CocktailFinder", code: 404, userInfo: [NSLocalizedDescriptionKey: "Коктейль не найден"])
            view.isLoading = false
        }
        
        return view
    }
}
