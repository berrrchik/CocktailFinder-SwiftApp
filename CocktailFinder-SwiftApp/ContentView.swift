import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var searchText = ""
    
    init() {
        UITabBar.appearance().backgroundColor = UIColor.white
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack() {
                SearchView()
            }
            .tabItem {
                Label("Поиск", systemImage: "magnifyingglass")
            }
            .tag(0)
            NavigationStack() {
                FavoriteCoctailsView()
            }
            .tabItem {
                Label("Избранное", systemImage: "heart")
            }
            .tag(1)
            NavigationStack() {
                FilterView()
                    .navigationTitle("Cocktail Finder")
            }
            .tabItem {
                Label("Категории", systemImage: "checklist")
            }
            .tag(2)
            NavigationStack() {
                RandomCocktailView()
            }
            .tabItem {
                Label("Рандом", systemImage: "dice")
            }
            .tag(3)
        }
    }
}

#Preview {
    ContentView()
}
