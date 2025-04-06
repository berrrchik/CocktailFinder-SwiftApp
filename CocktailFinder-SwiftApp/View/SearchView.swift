import SwiftUI
 
struct SearchView: View {
    let searchText: String

    var body: some View {
        NavigationStack {
            Text("Ищем \(searchText)")
        }
    }
}

#Preview {
    SearchView(searchText: "vodka")
}
