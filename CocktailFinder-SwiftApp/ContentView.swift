import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var searchText = ""
    
    init() {
        UITabBar.appearance().backgroundColor = UIColor.white
    }
    
    var body: some View {
        NavigationStack {
            TabView(selection: $selectedTab) {
                SearchView()
                    .tabItem {
                        Label("Поиск", systemImage: "magnifyingglass")
                    }
                    .tag(0)
                
                FilterView()
                    .navigationTitle("Cocktail Finder")
                    .tabItem {
                        Label("Категории", systemImage: "checklist")
                    }
                    .tag(1)
                
                FavoriteCoctailsView()
                    .tabItem {
                        Label("Избранное", systemImage: "heart")
                    }
                    .tag(2)
                
                RandomCocktailView()
                    .tabItem {
                        Label("Рандом", systemImage: "dice")
                    }
                    .tag(3)
            }
        }
    }
}

#Preview {
    ContentView()
}
