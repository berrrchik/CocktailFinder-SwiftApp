import SwiftUI

extension Color {
    static let customOrange = Color(red: 0.988, green: 0.416, blue: 0.039) // #FC6A0A
}

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var searchText = ""
    
    init() {
        UITabBar.appearance().backgroundColor = UIColor.white
        UITabBar.appearance().tintColor = UIColor(red: 0.988, green: 0.416, blue: 0.039, alpha: 1.0) // #FC6A0A
        UITabBar.appearance().unselectedItemTintColor = UIColor.gray
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
                FilterView()
                    .navigationTitle("Cocktail Finder")
            }
            .tabItem {
                Label("Категории", systemImage: "checklist")
            }
            .tag(1)
            NavigationStack() {
                FavoriteCoctailsView()
            }
            .tabItem {
                Label("Избранное", systemImage: "heart")
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
        .accentColor(.customOrange)
    }
}

#Preview {
    ContentView()
}
