import SwiftUI

struct FavoriteCoctailsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Здесь будут ваши любимые коктейли")
                .font(.title3)
            Image(systemName: "heart.fill")
                .font(.title)
                .foregroundColor(.blue)
        }
        .navigationTitle("Избранное")
    }
}

#Preview {
    FavoriteCoctailsView()
}
