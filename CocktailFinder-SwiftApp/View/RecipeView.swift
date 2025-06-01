import SwiftUI
import SDWebImageSwiftUI

struct RecipeView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @StateObject var viewModel: RecipeViewModel
    
    init(drinkId: String = "11007") {
        _viewModel = StateObject(wrappedValue: RecipeViewModel(drinkId: drinkId))
    }
    
    init(cocktail: Cocktail) {
        _viewModel = StateObject(wrappedValue: RecipeViewModel(cocktail: cocktail))
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if viewModel.isLoading {
                    ProgressView("Загрузка...")
                        .padding()
                } else if let error = viewModel.error {
                    errorView
                } else if let cocktail = viewModel.cocktail {
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
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("ИНГРЕДИЕНТЫ")
                                .font(.headline)
                                .fontWeight(.medium)
                                .foregroundColor(.gray)
                                .padding(.horizontal)
                            
                            ingredientsCard(ingredients: cocktail.ingredients)
                                .padding(.horizontal)
                        }
                        .padding(.vertical)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("ИНСТРУКЦИЯ")
                                .font(.headline)
                                .fontWeight(.medium)
                                .foregroundColor(.gray)
                                .padding(.horizontal)
                            
                            servedInCard(glass: cocktail.glass)
                                .padding(.horizontal)
                            
                            instructionsCard(instructions: cocktail.instructions)
                                .padding(.horizontal)
                        }
                        .padding(.bottom, 30)
                    }
                } else {
                    Text("Нет данных о коктейле")
                        .padding()
                }
            }
            .background(backgroundColor)
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
                        .foregroundColor(.customOrange)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.toggleFavorite()
                    }) {
                        Image(systemName: viewModel.isFavorite ? "heart.fill" : "heart")
                            .foregroundColor(viewModel.isFavorite ? .red : .black)
                    }
                }
            }
        }
    }
    
    var backgroundColor: Color {
        colorScheme == .dark ? Color.black : Color(UIColor.systemBackground)
    }
    
    var cardBackgroundColor: Color {
        colorScheme == .dark ? Color(UIColor.systemGray6) : Color.white
    }
    
    func ingredientsCard(ingredients: [Cocktail.Ingredient]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(Array(ingredients.enumerated()), id: \.element) { index, ingredient in
                HStack {
                    Text("\(index + 1).")
                        .font(.body)
                    Text(ingredient.name)
                        .font(.body)
                        .fontWeight(.medium)
                    Spacer()
                    Text(ingredient.measure)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardBackgroundColor)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
    }
    
    func servedInCard(glass: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("СЕРВИРОВКА")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.gray)
            
            Text(glass)
                .font(.title3)
                .fontWeight(.bold)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardBackgroundColor)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
    }
    
    func instructionsCard(instructions: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("ПРИГОТОВЛЕНИЕ")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.gray)
            
            Text(instructions)
                .font(.body)
                .lineSpacing(6)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardBackgroundColor)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
    }
    
    var errorView: some View {
        VStack {
            Text("Ошибка загрузки")
                .font(.headline)
            
            Text(viewModel.error?.localizedDescription ?? "Неизвестная ошибка")
                .multilineTextAlignment(.center)
                .padding()
            
            Button("Повторить") {
                viewModel.loadCocktailData()
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        return layout(proposal: proposal, subviews: subviews, cache: &cache).1
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let offsets = layout(proposal: proposal, subviews: subviews, cache: &cache).0
        for index in offsets.indices {
            subviews[index].place(at: CGPoint(x: offsets[index].x + bounds.minX, y: offsets[index].y + bounds.minY), proposal: proposal)
        }
    }
    
    func layout(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> ([CGPoint], CGSize) {
        guard !subviews.isEmpty else { return ([], .zero) }
        let width = proposal.width ?? 0
        var heights: [CGFloat] = [0]
        var offsets: [CGPoint] = []
        var currentPosition: CGPoint = .zero
        
        for subview in subviews {
            let viewDimension = subview.sizeThatFits(.unspecified)
            
            if currentPosition.x + viewDimension.width > width && currentPosition.x > 0 {
                currentPosition.x = 0
                currentPosition.y += (heights.last ?? 0) + spacing
                heights.append(0)
            }
            
            offsets.append(currentPosition)
            currentPosition.x += viewDimension.width + spacing
            
            if !heights.isEmpty {
                heights[heights.count - 1] = max(heights.last ?? 0, viewDimension.height)
            }
        }
        
        let height = heights.reduce(0, +) + spacing * CGFloat(max(0, heights.count - 1))
        return (offsets, CGSize(width: width, height: height))
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
            view.viewModel.error = NSError(domain: "CocktailFinder", code: 404, userInfo: [NSLocalizedDescriptionKey: "Коктейль не найден"])
            view.viewModel.isLoading = false
        }
        
        return view
    }
}
