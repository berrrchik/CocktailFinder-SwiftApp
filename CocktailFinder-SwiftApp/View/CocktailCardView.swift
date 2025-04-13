import SwiftUI
import SDWebImageSwiftUI

struct CocktailCardView: View {
    @StateObject private var viewModel: CocktailCardViewModel
    let imageHeight: CGFloat
    
    init(cocktail: Cocktail, imageHeight: CGFloat = 170) {
        _viewModel = StateObject(wrappedValue: CocktailCardViewModel(cocktail: cocktail))
        self.imageHeight = imageHeight
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            ZStack(alignment: .topTrailing) {
                WebImage(url: URL(string: viewModel.cocktail.thumbnail))
                    .resizable()
                    .indicator(.activity)
                    .transition(.fade(duration: 0.5))
                    .scaledToFill()
                    .frame(height: imageHeight)
                    .clipped()
                
                Button(action: {
                    viewModel.toggleFavorite()
                }) {
                    Image(systemName: viewModel.isFavorite ? "heart.fill" : "heart")
                        .foregroundColor(viewModel.isFavorite ? .red : .white)
                        .padding(8)
                        .background(Circle().fill(Color.black.opacity(0.5)))
                        .shadow(radius: 2)
                }
                .padding(8)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.cocktail.name)
                    .font(.headline)
                    .lineLimit(1)
                    .foregroundStyle(.black)
                
                HStack {
                    Text(viewModel.cocktail.alcoholic)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                        .foregroundStyle(.black)
                    
                    Spacer()
                    
                    Text(viewModel.cocktail.category)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            .padding(8)
        }
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
        .onAppear {
            viewModel.checkIsFavorite()
        }
    }
}

struct CocktailCardView_Previews: PreviewProvider {
    static var previews: some View {
        CocktailCardPreview()
    }
}

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
