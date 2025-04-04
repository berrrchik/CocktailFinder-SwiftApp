import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack() {
                Text("Поиск")
                    .navigationTitle("Cocktail Finder")
            }
            .tabItem {
                Label("Поиск", systemImage: "magnifyingglass")
            }
            .tag(0)
            NavigationStack() {
                Text("Избранное")
                    .navigationTitle("Cocktail Finder")
            }
            .tabItem {
                Label("Избранное", systemImage: "heart")
            }
            .tag(1)
            NavigationStack() {
                Text("Случайный коктейль")
                    .navigationTitle("Cocktail Finder")
            }
            .tabItem {
                Label("Случайный коктейль", systemImage: "dice")
            }
            .tag(2)
        }
    }
}

#Preview {
    ContentView()
}
